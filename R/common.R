library(dplyr)
library(httr2)
library(jsonlite)
library(purrr)
library(readr)
library(stringr)
library(tibble)
library(xml2)

TEAM_LOGINS <- c(
  "gabembecker",
  "kuwisdelu",
  "jaganmn2",
  "jeroenooms",
  "michaelchirico4",
  "cgmossa",
  "kevinushey",
  "lluis.revilla",
  "ikrylov"
)

TRIAGE_CATEGORIES <- c(
  "Major patches",
  "Minor patches",
  "Recommended closures",
  "Needs more information",
  "Needs core developer discussion"
)

BUGZILLA_URL <- "https://bugs.r-project.org/show_bug.cgi?id="

node_text <- function(node, xpath) {
  value <- xml2::xml_text(xml_find_first(node, xpath), trim = TRUE)
  if (is.na(value)) "" else value
}

find_data_dir <- function(root, name) {
  direct <- file.path(root, name)
  if (dir.exists(direct)) return(direct)
  
  candidates <- list.dirs(root, recursive = TRUE, full.names = TRUE)
  candidates <- candidates[basename(candidates) == name]
  
  if (length(candidates) != 1) {
    stop("Could not uniquely locate '", name, "' under ", root, ".")
  }
  
  candidates[[1]]
}

parse_comments <- function(bug) {
  nodes <- xml_find_all(bug, "./long_desc")
  
  map_dfr(nodes, function(node) {
    tibble(
      comment_id = node_text(node, "./commentid"),
      comment_count = suppressWarnings(
        as.integer(node_text(node, "./comment_count"))
      ),
      who = node_text(node, "./who"),
      date = node_text(node, "./bug_when"),
      text = node_text(node, "./thetext")
    )
  })
}

decode_attachment <- function(node, max_chars = 20000) {
  data <- node_text(node, "./data")
  if (!nzchar(data)) return("")
  
  decoded <- tryCatch(
    rawToChar(jsonlite::base64_dec(gsub("\\s+", "", data))),
    error = function(e) ""
  )
  
  if (nchar(decoded) > max_chars) {
    decoded <- paste0(substr(decoded, 1, max_chars), "\n[attachment truncated]")
  }
  
  decoded
}

parse_attachments <- function(bug) {
  nodes <- xml_find_all(bug, "./attachment")
  
  if (length(nodes) == 0) {
    return(tibble(
      attachment_id = character(),
      date = character(),
      description = character(),
      filename = character(),
      type = character(),
      attacher = character(),
      content = character()
    ))
  }
  
  map_dfr(nodes, function(node) {
    tibble(
      attachment_id = node_text(node, "./attachid"),
      date = node_text(node, "./date"),
      description = node_text(node, "./desc"),
      filename = node_text(node, "./filename"),
      type = node_text(node, "./type"),
      attacher = node_text(node, "./attacher"),
      content = decode_attachment(node)
    )
  })
}

read_bug_xml <- function(path) {
  raw <- readBin(path, "raw", n = file.info(path)$size)
  
  text <- iconv(
    rawToChar(raw),
    from = "UTF-8",
    to = "UTF-8",
    sub = "\uFFFD"
  )
  
  read_xml(text, options = c("RECOVER", "NOERROR", "NOWARNING"))
}

parse_bug <- function(path) {
  doc <- read_bug_xml(path)
  bug <- xml_find_first(doc, ".//bug")
  
  if (inherits(bug, "xml_missing")) {
    stop("No <bug> element in ", path)
  }
  
  comments <- parse_comments(bug)
  attachments <- parse_attachments(bug)
  
  list(
    bug_id = as.integer(node_text(bug, "./bug_id")),
    summary = node_text(bug, "./short_desc"),
    component = node_text(bug, "./component"),
    status = node_text(bug, "./bug_status"),
    resolution = node_text(bug, "./resolution"),
    reporter = node_text(bug, "./reporter"),
    changed = node_text(bug, "./delta_ts"),
    comments = comments,
    attachments = attachments
  )
}

parse_all_bugs <- function(bugs_dir) {
  paths <- list.files(bugs_dir, pattern = "\\.xml$", full.names = TRUE)
  
  bugs <- map(paths, function(path) {
    tryCatch(
      parse_bug(path),
      error = function(e) {
        warning("Could not parse ", basename(path), ": ", conditionMessage(e))
        NULL
      }
    )
  })
  
  compact(bugs)
}

dump_updated <- function(bugs) {
  changed <- vapply(bugs, `[[`, character(1), "changed")
  changed <- changed[nzchar(changed)]
  max(changed)
}

last_triager_comment_date <- function(bug) {
  comments <- bug$comments |>
    filter(.data$who %in% TEAM_LOGINS)
  
  if (nrow(comments) == 0) return(NA_character_)
  
  max(comments$date)
}

attachment_looks_like_patch <- function(row) {
  metadata <- paste(row$description, row$filename)
  
  if (str_detect(metadata, regex("\\b(patch|diff)\\b", ignore_case = TRUE))) {
    return(TRUE)
  }
  
  content <- row$content %||% ""
  
  str_detect(
    content,
    regex(
      "(^|\\n)(Index: |diff --git |@@ |--- .+\\n\\+\\+\\+ )",
      multiline = TRUE
    )
  )
}

team_patch_info <- function(bug) {
  attachments <- bug$attachments |> filter(attacher %in% TEAM_LOGINS)
  
  if (nrow(attachments) == 0) return(tibble())
  
  is_patch <- map_lgl(seq_len(nrow(attachments)), function(i) {
    attachment_looks_like_patch(attachments[i, , drop = FALSE])
  })
  
  attachments |>
    filter(is_patch) |>
    arrange(date)
}

bug_dossier <- function(bug) {
  comments <- bug$comments |>
    mutate(
      text = str_replace_all(text, "\r\n?", "\n"),
      entry = paste0(
        "COMMENT ", comment_count, " — ", who, " — ", date, "\n", text
      )
    )
  
  attachments <- bug$attachments |>
    mutate(
      entry = paste0(
        "ATTACHMENT ", attachment_id, " — ", attacher, " — ", date, "\n",
        description, " (", filename, ", ", type, ")\n",
        if_else(nzchar(content), content, "[attachment content unavailable]")
      )
    )
  
  paste(
    paste0("Bug ", bug$bug_id, ": ", bug$summary),
    paste0("Component: ", bug$component),
    paste0("Current status: ", bug$status),
    paste0("Reporter: ", bug$reporter),
    "",
    "COMMENTS",
    paste(comments$entry, collapse = "\n\n"),
    "",
    "ATTACHMENTS",
    if (nrow(attachments)) {
      paste(attachments$entry, collapse = "\n\n")
    } else {
      "[none]"
    },
    sep = "\n"
  )
}

hash_text <- function(x) {
  path <- tempfile()
  writeLines(x, path, useBytes = TRUE)
  on.exit(unlink(path), add = TRUE)
  unname(tools::md5sum(path))
}

gemini_classify <- function(dossier, prompt, api_key, model) {
  schema <- list(
    type = "object",
    properties = list(
      category = list(type = "string", enum = TRIAGE_CATEGORIES),
      reason = list(
        type = "string",
        description = paste(
          "A concise reason for the classification.",
          "Use at most two sentences."
        )
      ),
      confidence = list(
        type = "string",
        enum = c("high", "medium", "low")
      )
    ),
    required = c("category", "reason", "confidence")
  )
  
  body <- list(
    contents = list(
      list(
        parts = list(
          list(text = paste(prompt, dossier, sep = "\n\n"))
        )
      )
    ),
    generationConfig = list(
      responseMimeType = "application/json",
      responseSchema = schema
    )
  )
  
  url <- paste0(
    "https://generativelanguage.googleapis.com/v1beta/models/",
    model,
    ":generateContent"
  )
  
  response <- request(url) |>
    req_headers("x-goog-api-key" = api_key) |>
    req_body_json(body, auto_unbox = TRUE) |>
    req_retry(max_tries = 3) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()
  
  if (resp_status(response) >= 400) {
    stop(resp_body_string(response))
  }
  
  parsed <- resp_body_json(response, simplifyVector = FALSE)
  text <- parsed$candidates[[1]]$content$parts[[1]]$text
  result <- fromJSON(text, simplifyVector = TRUE)
  
  if (!result$category %in% TRIAGE_CATEGORIES) {
    stop("Unexpected AI category: ", result$category)
  }
  
  result
}

read_cache <- function(path) {
  if (!file.exists(path)) {
    return(tibble(
      bug_id = integer(),
      input_hash = character(),
      category = character(),
      reason = character(),
      confidence = character(),
      model = character(),
      reviewed_at = character()
    ))
  }
  
  read_csv(path, show_col_types = FALSE)
}

classify_triaged <- function(bugs, cache_path, prompt_path) {
  api_key <- Sys.getenv("GEMINI_API_KEY")
  model <- Sys.getenv("GEMINI_MODEL", "gemini-3.5-flash-lite")
  
  if (!nzchar(api_key)) stop("GEMINI_API_KEY is not set.")
  
  prompt <- paste(readLines(prompt_path, warn = FALSE), collapse = "\n")
  cache <- read_cache(cache_path)
  output <- vector("list", length(bugs))
  
  for (i in seq_along(bugs)) {
    bug <- bugs[[i]]
    dossier <- bug_dossier(bug)
    input_hash <- hash_text(dossier)
    
    cached <- cache |>
      filter(bug_id == bug$bug_id, .data$input_hash == input_hash)
    
    if (nrow(cached) > 0) {
      result <- cached[1, ]
    } else {
      message("Classifying Bug ", bug$bug_id, " with ", model)
      ai <- gemini_classify(dossier, prompt, api_key, model)
      
      result <- tibble(
        bug_id = bug$bug_id,
        input_hash = input_hash,
        category = ai$category,
        reason = ai$reason,
        confidence = ai$confidence,
        model = model,
        reviewed_at = format(Sys.time(), tz = "UTC", usetz = TRUE)
      )
      
      cache <- bind_rows(
        cache |> filter(bug_id != bug$bug_id),
        result
      )
    }
    
    output[[i]] <- tibble(
      bug_id = bug$bug_id,
      summary = bug$summary,
      component = bug$component,
      reporter = bug$reporter,
      status = bug$status,
      last_triager_comment = last_triager_comment_date(bug),
      category = result$category[[1]],
      reason = result$reason[[1]],
      confidence = result$confidence[[1]],
      reviewed_at = result$reviewed_at[[1]],
      model = result$model[[1]],
      bugzilla_url = paste0(BUGZILLA_URL, bug$bug_id)
    )
  }
  
  write_csv(cache |> arrange(bug_id), cache_path)
  bind_rows(output)
}

additional_team_patches <- function(bugs) {
  map_dfr(bugs, function(bug) {
    if (!bug$reporter %in% TEAM_LOGINS) return(tibble())
    if (bug$status == "TRIAGED") return(tibble())
    if (bug$status %in% c("CLOSED", "RESOLVED")) return(tibble())
    
    patches <- team_patch_info(bug)
    if (nrow(patches) == 0) return(tibble())
    
    tibble(
      bug_id = bug$bug_id,
      summary = bug$summary,
      component = bug$component,
      reporter = bug$reporter,
      status = bug$status,
      patch_date = min(patches$date),
      patch_count = nrow(patches),
      bugzilla_url = paste0(BUGZILLA_URL, bug$bug_id)
    )
  })
}

markdown_bug <- function(id, summary, date) {
  link <- paste0("[Bug ", id, "](", BUGZILLA_URL, id, ")")
  date <- format(as.POSIXct(date, tz = "UTC"), "%Y-%m-%d")
  paste0("* ", link, " — ", summary, " (", date, ")")
}

write_readme <- function(triaged, patches, dump_date, path = "README.md") {
  con <- file(path, open = "wt", encoding = "UTF-8")
  on.exit(close(con))
  
  write <- function(...) writeLines(c(...), con, useBytes = TRUE)
  
  write(
    "# Current TRIAGED bugs and patches from Triage Team",
    "",
    paste0(
      "_Automatically generated from the R Bugzilla dump updated ",
      format(as.POSIXct(dump_date, tz = "UTC"), "%Y-%m-%d"),
      "._"
    ),
    "",
    "## Triaged bugs",
    "",
    "_Dates show the most recent triager comment on the bug._",
    ""
  )
  
  for (category in TRIAGE_CATEGORIES) {
    x <- triaged |>
      filter(.data$category == .env$category) |>
      arrange(last_triager_comment, bug_id)
    
    write(paste0("### ", category), "")
    
    if (nrow(x) == 0) {
      write("_None._", "")
      next
    }
    
    lines <- markdown_bug(x$bug_id, x$summary, x$last_triager_comment)
    write(lines, "")
  }
  
  write(
    "## Additional Triage Team patches awaiting review",
    "",
    "_Dates show when the patch was submitted._",
    ""
  )
  
  components <- sort(unique(patches$component))
  
  if (length(components) == 0) {
    write("_None._", "")
  } else {
    for (component in components) {
      x <- patches |>
        filter(.data$component == .env$component) |>
        arrange(patch_date, bug_id)
      
      write(
        paste0("### ", component),
        "",
        markdown_bug(x$bug_id, x$summary, x$patch_date),
        ""
      )
    }
  }
  
  write(
    "## About this report",
    "",
    paste(
      "This report is generated automatically from R Bugzilla data.",
      "The classification of TRIAGED bugs is generated with the",
      "assistance of generative AI and should be treated as a summary",
      "to support, rather than replace, human review."
    ),
    "",
    paste(
      "The code for this project has been developed with substantial",
      "assistance from generative AI. The maintainers review and test",
      "generated code before it is incorporated into the repository."
    ),
    ""
  )
}

plain_bug <- function(id, summary, date) {
  date <- format(as.POSIXct(date, tz = "UTC"), "%Y-%m-%d")
  paste0("* Bug ", id, " — ", summary, " (", date, ")")
}

write_plain_text_report <- function(
    triaged,
    patches,
    readme_url,
    path = "monthly-email.txt"
) {
  con <- file(path, open = "wt", encoding = "UTF-8")
  on.exit(close(con))
  
  write <- function(...) writeLines(c(...), con, useBytes = TRUE)
  
  write(
    "Current TRIAGED bugs and patches from Triage Team",
    "=================================================",
    "",
    "Triaged bugs",
    "-------------",
    "",
    "Dates show the most recent triager comment on the bug.",
    ""
  )
  
  for (category in TRIAGE_CATEGORIES) {
    x <- triaged |>
      filter(.data$category == .env$category) |>
      arrange(last_triager_comment, bug_id)
    
    if (nrow(x) == 0) next
    
    write(
      paste0(category, " (", nrow(x), ")"),
      "",
      plain_bug(x$bug_id, x$summary, x$last_triager_comment),
      ""
    )
  }
  
  write(
    "Additional Triage Team patches awaiting review",
    "-----------------------------------------------",
    "",
    "Dates show when the patch was submitted.",
    ""
  )
  
  components <- sort(unique(patches$component))
  
  if (length(components) == 0) {
    write("None.", "")
  } else {
    for (component in components) {
      x <- patches |>
        filter(.data$component == .env$component) |>
        arrange(patch_date, bug_id)
      
      write(
        paste0(component, " (", nrow(x), ")"),
        "",
        plain_bug(x$bug_id, x$summary, x$patch_date),
        ""
      )
    }
  }
  
  write("Full current report (updated daily):", readme_url, "")
}