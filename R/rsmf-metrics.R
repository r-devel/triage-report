# Functions to compute quarterly RSMF metrics from the daily Bugzilla dump.
# The dump is the primary source; Bugzilla/GitHub APIs are used only for
# history, attachments, and pull-request evidence not present in the dump.

source("R/common.R")

BUGZILLA_USERS <- TEAM_LOGINS[!TEAM_LOGINS %in% c("lluis.revilla", "ikrylov")]
GITHUB_USERS <- c(
  "Gabriel Becker" = "gmbecker",
  "Kylie Bemis" = "kuwisdelu",
  "Mikael Jagan" = "jaganmn",
  "Jeroen Ooms" = "jeroen",
  "Michael Chirico" = "MichaelChirico",
  "Mossa Reimert" = "CGMossa",
  "Kevin Ushey" = "kevinushey"
)
CORE_GITHUB <- c(
  "sarkar" = "deepayan",
  "turner" = "hturner",
  "jagan" = "jaganmn",
  "chambers" = "",
  "hornik" = "kurthornik",
  "lawrence" = "lawremi",
  "ligges" = "uligges",
  "tierney" = "ltierney",
  "maechler" = "mmaechler",
  "plummer" = "martynplummer",
  "murrell" = " pmur002",
  "dalgaard" = "pdalgd",
  "ripley" = "",
  "meyer" = "bastistician",
  "urbanek" = "s-u",
  "lumley" = "tslumley"
)

BUGZILLA_BASE <- "https://bugs.r-project.org"
GITHUB_API <- "https://api.github.com"
GITHUB_REPO <- "r-devel/r-svn"

# assume reporting in month following end of quarter, as required
END_DATE <- as.Date(format(Sys.Date(), "%Y-%m-01")) - 1
START_DATE <- as.Date(format(
  seq(END_DATE, by = "-2 months", length.out = 2)[2],
  "%Y-%m-01"
))

# over-ride start and end date here if required
# START_DATE <- as.Date("2026-05-01")
# END_DATE <- as.Date("2026-07-31")

REPORT_ID <- paste0(format(START_DATE, "%Y-%m"), "_", format(END_DATE, "%Y-%m"))
DATA_ROOT <- if (length(commandArgs(trailingOnly = TRUE))) {
  commandArgs(trailingOnly = TRUE)[[1]] 
} else "bug-stats"
CACHE_DIR <- file.path("data", "quarterly-cache", REPORT_ID)
OUTPUT_DIR <- file.path("rsmf-quarterly-reports", REPORT_ID)
dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

start_time <- as.POSIXct(paste0(START_DATE, " 00:00:00"), tz = "Europe/London")
end_time <- as.POSIXct(paste0(END_DATE, " 23:59:59"), tz = "Europe/London")

in_period <- function(x) {
  if (is.null(x) || length(x) == 0L || is.na(x) || !nzchar(x)) return(FALSE)
  time <- as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%S", tz = "Europe/London")
  if (is.na(time)) time <- as.POSIXct(x, tz = "Europe/London")
  !is.na(time) && time >= start_time && time <= end_time
}

uk_time <- function(x) {
  if (is.null(x) || length(x) == 1L && !nzchar(x)) {
    return(as.POSIXct(NA))
  }
  as.POSIXct(x, tz = "Europe/London")
}

full_name <- function(login, users) {
  names(users)[match(login, users)]
}

first_name <- function(login, users) {
  sub(" .*", "", full_name(login, users))
}

bug_url <- function(id) paste0(BUGZILLA_BASE, "/show_bug.cgi?id=", id)
comment_url <- function(id, count) paste0(bug_url(id), "#c", count)
attachment_comment_url <- function(bug, attachment_id) {
  if (!length(attachment_id)) return(bug_url(bug$bug_id))
  
  comments <- bug$comments
  i <- grep(paste("Created attachment", attachment_id), comments$text)[1]
  paste0(bug_url(bug$bug_id), "#c", comments$comment_count[i])
}

# Keep the login from the CSV filename: common.R's read_contribs() deliberately
# deduplicates across files and therefore is not suitable for attribution.
read_contributor_index <- function(contribs_dir) {
  paths <- list.files(contribs_dir, pattern = "\\.csv$", full.names = TRUE)
  logins <- tools::file_path_sans_ext(basename(paths))
  keep <- logins %in% BUGZILLA_USERS
  paths <- paths[keep]
  logins <- logins[keep]
  if (!length(paths)) {
    stop("No contributor CSVs found for the selected seven logins.")
  }
  purrr::map2_dfr(paths, logins, function(path, login) {
    readr::read_csv(path, 
                    col_types = readr::cols(.default = readr::col_character()), 
                    show_col_types = FALSE) |>
      mutate(login = login, bug_id = as.integer(bug_id), 
             resolution = trimws(resolution))
  }) |>
    filter(!is.na(bug_id)) |>
    arrange(login, bug_id, desc(changeddate)) |>
    distinct(login, bug_id, .keep_all = TRUE)
}

# Parse the XML included in the dump. Attachments are often absent from the
# dump, so attachment metadata is fetched separately only for closed-fixed bugs.
read_dump_bug <- function(path) {
  doc <- read_bug_xml(path)
  bug <- xml2::xml_find_first(doc, ".//bug")
  if (inherits(bug, "xml_missing")) stop("Missing <bug> element in ", path)
  comments <- parse_comments(bug)
  if (!all(c("comment_id", "comment_count", "who", "date", "text") %in% 
           names(comments))) {
    comments <- tibble(
      comment_id = character(), comment_count = integer(), who = character(),
      date = character(), text = character()
    )
  }
  list(
    bug_id = as.integer(node_text(bug, "./bug_id")),
    summary = node_text(bug, "./short_desc"),
    reporter = node_text(bug, "./reporter"),
    created = node_text(bug, "./creation_ts"),
    changed = node_text(bug, "./delta_ts"),
    status = node_text(bug, "./bug_status"),
    resolution = node_text(bug, "./resolution"),
    comments = comments,
    attachments = parse_attachments(bug)
  )
}

api_cache_path <- function(key) {
  file.path(CACHE_DIR, paste0(gsub("[^A-Za-z0-9_-]", "_", key), ".rds"))
}
api_cached <- function(key, fetch) {
  path <- api_cache_path(key)
  if (file.exists(path)) return(readRDS(path))
  value <- fetch()
  saveRDS(value, path)
  value
}

bugzilla_api <- function(path) {
  request(paste0(BUGZILLA_API, path)) |>
    req_headers(Accept = "application/json") |>
    req_retry(max_tries = 3) |>
    req_perform() |>
    resp_body_json(simplifyVector = FALSE)
}

get_bug_history <- function(id, changed) {
  key <- paste0("history-", id, "-", gsub("[^0-9]", "", changed))
  api_cached(key, function() bugzilla_api(paste0("bug/", id, "/history")))
}

get_bug_attachments <- function(id, changed) {
  key <- paste0("attachments-", id, "-", gsub("[^0-9]", "", changed))
  api_cached(key, function() bugzilla_api(paste0("bug/", id, "/attachment")))
}

get_bug_comments <- function(id, changed) {
  key <- paste0("comments-", id, "-", gsub("[^0-9]", "", changed))
  api_cached(key, function() bugzilla_api(paste0("bug/", id, "/comment")))
}

api_comments_as_tbl <- function(result, id) {
  comments <- result$bugs[[as.character(id)]]$comments %||% list()
  if (!length(comments)) {
    return(tibble(comment_id = character(), comment_count = integer(), 
                  who = character(), date = character(), text = character()))
  }
  purrr::map_dfr(comments, function(x) tibble(
    comment_id = as.character(x$id), 
    comment_count = as.integer(x$count),
    who = x$creator %||% "", 
    date = x$creation_time %||% "", 
    text = x$text %||% ""
  ))
}

history_events <- function(result, id) {
  history <- result$bugs[[1]]$history %||% list()
  if (!length(history)) {
    return(tibble(when = character(), who = character(), field = character(), 
                  removed = character(), added = character()))
  }
  purrr::map_dfr(history, function(event) {
    changes <- event$changes %||% list()
    if (!length(changes)) return(tibble())
    purrr::map_dfr(changes, function(change) tibble(
      when = event$when %||% "", who = event$who %||% "",
      field = change$field_name %||% "", removed = change$removed %||% "",
      added = change$added %||% ""
    ))
  })
}

closure_from_history <- function(events) {
  status_events <- events |>
    filter(field == "status", toupper(added) == "CLOSED") |>
    mutate(time = uk_time(when)) |>
    filter(!is.na(time)) |>
    arrange(time)
  if (!nrow(status_events)) return(list(date = as.POSIXct(NA), resolution = ""))
  close <- status_events[1, ]
  resolutions <- events |>
    filter(field == "resolution") |>
    mutate(time = uk_time(when)) |>
    filter(!is.na(time), time <= close$time) |>
    arrange(time)
  resolution <- if (nrow(resolutions)) tail(resolutions$added, 1) else ""
  list(date = close$time, resolution = resolution)
}

svn_revisions <- function(text) {
  if (is.null(text) || !length(text) || is.na(text)) return(character())
  # Remove fenced code blocks (including multi-line blocks)
  text <- stringr::str_remove_all(text, "(?s)```.*?```")
  # Find revision numbers
  pattern <- "\\b(?:[rc][0-9]+|revision\\s+[0-9]+|svn\\s+rev\\s+[0-9]+)\\b"
  x <- stringr::str_extract_all(text, pattern) |>
    unlist(use.names = FALSE)
  if (!length(x)) return(x)
  #standardize to "r[0-9]+" form
  x <- stringr::str_extract(x, "[0-9]+")
  x <- unique(x[as.integer(x) > 1000])
  paste0("r", x)
}

svn_commit_url <- function(revision) {
  rev <- sub("^r", "", revision)
  svn_id <- paste0("https://svn.r-project.org/R/trunk@", rev)
  key <- paste0("svn-commit-", rev)
  result <- github_request(
    "search/commits",
    list(q = paste0("repo:", GITHUB_REPO, " ",  svn_id), per_page = 10),
    key
  )
  items <- result$items %||% list()
  exact <- purrr::keep(items, function(x) {
    stringr::str_detect(x$commit$message %||% "", fixed(svn_id))
  })
  if (length(exact)) exact[[1]]$html_url %||% "" else ""
}

# The API exposes attachment creator, patch flag, date and summary. We do not
# download patch bodies unless metadata is inconclusive; uncertain rows remain
# visible for contributor review.
attachment_records <- function(result, id) {
  result$bugs[[as.character(id)]] %||% list()
}

looks_like_patch <- function(x) {
  if (isTRUE(x$is_patch)) return(TRUE)
  metadata <- paste(x$summary %||% "", x$file_name %||% "", 
                    x$content_type %||% "")
  grepl("patch|diff", metadata, ignore.case = TRUE) || 
    grepl("\\.(patch|diff)$", x$file_name %||% "", ignore.case = TRUE)
}

extract_bug_data <- function(index, bugs_dir, end_date) {
  ids <- sort(unique(index$bug_id))
  output <- vector("list", length(ids))
  names(output) <- as.character(ids)
  for (i in seq_along(ids)) {
    id <- ids[[i]]
    path <- file.path(bugs_dir, paste0(id, ".xml"))
    bug <- if (file.exists(path)) {
      tryCatch(read_dump_bug(path), error = function(e) NULL) 
    } else NULL
    # For the seven report contributors, their CSV's changeddate is the
    # freshness marker. A stale/missing XML file is refreshed via targeted API.
    changed <- index$changeddate[index$bug_id == id]
    changed <- changed[!is.na(changed) & nzchar(changed)]
    changed <- if (length(changed)) max(changed) else ""
    same_timestamp <- !is.null(bug) && !is.na(uk_time(bug$changed)) &&
      !is.na(uk_time(changed)) && 
      as.numeric(uk_time(bug$changed)) == as.numeric(uk_time(changed))
    refresh <- !same_timestamp ||
      (uk_time(changed) < uk_time(paste0(end_date, " 23:59:59")))
    if (refresh) {
      message("Bugzilla fallback for bug ", id, " (missing or stale XML)")
      fetch <- function() list(
        bug = bugzilla_api(paste0("bug/", id)),
        comments = bugzilla_api(paste0("bug/", id, "/comment"))
      )
      if (uk_time(changed) < uk_time(paste0(end_date, " 23:59:59"))) {
        # Refresh to capture comments added during the reporting period
        api <- fetch()
      } else {
        api <- api_cached(
          paste0("bug-comments-", id, "-", gsub("[^0-9]", "", changed)),
          fetch
        )
      }
      b <- api$bug$bugs[[1]]
      bug <- list(
        bug_id = id, summary = b$summary %||% "", reporter = b$creator %||% "",
        created = b$creation_time %||% "", 
        changed = b$last_change_time %||% changed,
        status = b$status %||% "", resolution = b$resolution %||% "",
        comments = api_comments_as_tbl(api$comments, id), attachments = tibble()
      )
    }
    bug$changed <- changed
    output[[i]] <- bug
  }
  output
}

triaged_rows <- function(bugs, index) {
  rows <- list()
  n <- 0L
  for (bug in bugs) {
    # If the last archive update predates the reporting period, no event in
    # this period can have occurred on the bug.
    last_changed <- suppressWarnings(as.Date(substr(bug$changed, 1, 10)))
    if (!is.na(last_changed) && last_changed < as.Date(START_DATE)) next
    # Find bugs marked as TRIAGED in the reporting period
    history <- get_bug_history(bug$bug_id, bug$changed)
    events <- history_events(history, bug$bug_id) |>
      filter(field == "status", 
             toupper(added) == "TRIAGED",
             who %in% BUGZILLA_USERS,
             who != bug$reporter) |>
      mutate(time = uk_time(when)) |>
      filter(!is.na(time), time >= start_time, time <= end_time) |>
      arrange(time)
    if (nrow(events)) {
      confirmed <- events |>
        group_by(who) |>
        summarise(time = min(time), event_count = n(), .groups = "drop")
      for (j in seq_len(nrow(confirmed))) {
        login <- confirmed$who[[j]]
        n <- n + 1L
        rows[[n]] <- tibble(
          contributor = names(BUGZILLA_API)[login], login = login,
          bug_id = bug$bug_id, bugzilla_url = bug_url(bug$bug_id),
          date = format(confirmed$time[[j]], "%Y-%m-%d %H:%M:%S", 
                        tz = "Europe/London"),
          evidence_url = bug_url(bug$bug_id),
          evidence = paste0("Bugzilla status history: changed to TRIAGED (", 
                            confirmed$event_count[[j]], 
                            " transition(s) in period)"),
          source = "Bugzilla history", confirmation = "Yes", notes = ""
        )
      }
    }
    # Preserve review candidates for contributors without a matching
    # TRIAGED transition on this bug, even if another contributor did make
    # a confirmed transition.
    comments <- bug$comments |>
      filter(who %in% BUGZILLA_USERS,
             who != bug$reporter) |>
      mutate(time = uk_time(date)) |>
      filter(!is.na(time), time >= start_time, time <= end_time)
    if (nrow(comments)) {
      uncertain <- comments |>
        filter(!who %in% events$who) |>
        group_by(who) |>
        arrange(time, .by_group = TRUE) |>
        summarise(time = first(time), comment_count = first(comment_count),
                  n_comments = n(), .groups = "drop")
      for (j in seq_len(nrow(uncertain))) {
        login <- uncertain$who[[j]]
        n <- n + 1L
        rows[[n]] <- tibble(
          contributor = full_name(login, BUGZILLA_USERS), login = login,
          bug_id = bug$bug_id, bugzilla_url = bug_url(bug$bug_id),
          date = format(uncertain$time[[j]], "%Y-%m-%d %H:%M:%S",
                        tz = "Europe/London"),
          evidence_url = comment_url(bug$bug_id, uncertain$comment_count[[j]]),
          evidence = paste0(
            "Contributor comment; no matching TRIAGED ",
            "status-history event found (",
            uncertain$n_comments[[j]],
            " comment(s) in period)"
          ),
          source = "Bugzilla comment", confirmation = "Uncertain",
          notes = "Check whether contributor moved bug forward."
        )
      }
    }
  }
  if (length(rows)) bind_rows(rows) else tibble()
}

reported_rows <- function(bugs) {
  purrr::map_dfr(bugs, function(bug) {
    if (!bug$reporter %in% BUGZILLA_USERS || !in_period(bug$created)) 
      return(tibble())
    tibble(
      contributor = full_name(bug$reporter, BUGZILLA_USERS), 
      login = bug$reporter,
      bug_id = bug$bug_id, bugzilla_url = bug_url(bug$bug_id),
      date = format(uk_time(bug$created), "%Y-%m-%d %H:%M:%S", 
                    tz = "Europe/London"),
      evidence_url = bug_url(bug$bug_id),
      evidence = "Bugzilla reporter and creation timestamp",
      source = "Bugzilla", confirmation = "Yes", notes = ""
    )
  })
}

accepted_bugzilla_rows <- function(bugs) {
  rows <- list()
  n <- 0L
  for (bug in bugs) {
    message("checking bug ", bug$bug_id)
    history <- get_bug_history(bug$bug_id, bug$changed)
    events <- history_events(history, bug$bug_id)
    closed <- closure_from_history(events)
    if (is.na(closed$date) || closed$date < start_time || 
        closed$date > end_time || toupper(closed$resolution) != "FIXED") next
    
    attachments_result <- get_bug_attachments(bug$bug_id, bug$changed)
    attachments <- attachment_records(attachments_result, bug$bug_id)
    if (!length(attachments)) next
    attachments <- purrr::keep(attachments, function(x) !isTRUE(x$is_obsolete))
    patches <- purrr::keep(attachments, looks_like_patch)
    if (!length(patches)) next
    patch_logins <- vapply(patches,
                           function(x) x$creator %||% x$attacher %||% "",
                           character(1))
    comments <- bug$comments
    core_comments <- comments[comments$who %in% CORE_LOGINS,]
    svn_text <- paste(core_comments$text, collapse = "\n")
    revisions <- svn_revisions(svn_text)
    n_patches <- length(patches)
    n_revisions <- length(unique(revisions))
    # May be more revisions than patches, e.g. commit to trunk and R-patched
    revision_count_matches <- n_patches <= n_revisions
    revision_urls <- if (length(revisions)) {
      vapply(revisions, svn_commit_url, character(1)) 
    } else character()
    revision_text <- if (length(revisions)) {
      paste(revisions, collapse = ", ") 
    } else ""
    revision_comment_urls <- comments |>
      filter(grepl("\\br[0-9]+\\b", text)) |>
      transmute(url = comment_url(bug$bug_id, comment_count)) |>
      pull(url)
    
    for (patch in patches) {
      login <- patch$creator %||% patch$attacher %||% ""
      if (!login %in% BUGZILLA_USERS) next
      other_patch_authors <- setdiff(unique(patch_logins), login)
      explicitly_acknowledged <- FALSE
      acknowledgement <- ""
      if (nrow(core_comments)) {
        search_terms <- unique(c(first_name(login, BUGZILLA_USERS), 
                                 patch$summary %||% "", 
                                 patch$file_name %||% "", 
                                 as.character(patch$id %||% "")))
        search_terms <- search_terms[nzchar(search_terms)]
        for (term in search_terms) {
          hit <- which(grepl(term, core_comments$text, fixed = TRUE))
          if (length(hit)) {
            explicitly_acknowledged <- TRUE
            acknowledgement <- paste0("Core developer comment by ", 
                                      core_comments$who[hit[[1]]], " (", 
                                      core_comments$date[hit[[1]]], ")")
            break
          }
        }
      }
      certain <- revision_count_matches &&
        (!length(other_patch_authors) || explicitly_acknowledged)
      
      evidence <- if (!length(other_patch_authors)) {
        "All patch attachments on this bug are by this contributor" 
      } else if (explicitly_acknowledged) {
        acknowledgement 
      } else paste("Other contributors also attached patches;",
                   "no explicit attribution found in core-developer comments")
      n <- n + 1L
      attachment_id <- as.character(patch$id %||% "")
      n_url <- if (nzchar(attachment_id)) {
        attachment_comment_url(bug, attachment_id) 
      } else bug_url(bug$bug_id)
      rows[[n]] <- tibble(
        contributor = full_name(login, BUGZILLA_USERS), login = login,
        bug_id = bug$bug_id, bugzilla_url = bug_url(bug$bug_id),
        date = format(closed$date, "%Y-%m-%d %H:%M:%S", tz = "Europe/London"),
        patch_date = format(uk_time(patch$creation_time %||% 
                                     patch$creation_date %||% ""), 
                            "%Y-%m-%d %H:%M:%S", tz = "Europe/London"),
        evidence_url = n_url,
        evidence = paste0("Patch attachment ", attachment_id, ": ", 
                          patch$summary %||% 
                            patch$file_name %||% "(no description)", 
                          ". ", evidence),
        source = "Bugzilla patch attachment", svn_revisions = revision_text,
        commit_urls = paste(revision_urls[nzchar(revision_urls)], 
                            collapse = ", "),
        svn_comment_urls = paste(revision_comment_urls, collapse = ", "),
        confirmation = if (certain) "Yes" else "Uncertain",
        notes = if (certain) "" else {
          "Please confirm that this contributor's patch was the one accepted."
        }
      )
    }
  }
  if (length(rows)) bind_rows(rows) else tibble()
}

# GitHub PRs are supplementary to Bugzilla. Only merged PRs closed in-period
# are included, and the report retains the PR plus any linked r-svn revision.
github_request <- function(path, query = list(), key = NULL) {
  fetch <- function() {
    req <- request(paste0(GITHUB_API, "/", path)) |>
      req_headers(Accept = "application/vnd.github+json", 
                  `X-GitHub-Api-Version` = "2022-11-28")
    token <- Sys.getenv("GITHUB_TOKEN")
    if (nzchar(token)) req <- req |> req_auth_bearer_token(token)
    if (length(query)) req <- do.call(req_url_query, c(list(req), query))
    resp <- req |>
      req_retry(max_tries = 3) |>
      req_error(is_error = function(resp) FALSE) |>
      req_perform()
    
    if (httr2::resp_status(resp) >= 400) {
      message("HTTP status: ", httr2::resp_status(resp))
      message(httr2::resp_body_string(resp))
    } else {
      result <- httr2::resp_body_json(
        resp,
        simplifyVector = FALSE
      )
    }
  }
  if (is.null(key)) fetch() else api_cached(paste0("gh-", key), fetch)
}

has_bugzilla_title <- function(x) {
  any(stringr::str_detect(
    x,
    regex(
      "\\b(?:PR\\s*#?\\s*|Bugzilla\\s*#?\\s*|BZ-\\s*)[0-9]+\\b",
      ignore_case = TRUE
    )
  ), na.rm = TRUE)
}

has_bugzilla_link <- function(x) {
  any(stringr::str_detect(
    x,
    "https?://bugs\\.r-project\\.org/show_bug\\.cgi\\?id=[0-9]+"
  ), na.rm = TRUE)
}

github_pr_rows <- function() {
  rows <- list()
  n <- 0L
  for (login in GITHUB_USERS) {
    message("Getting PRs for ", login)
    # filtering by date does not seem to work
    q <- sprintf(
      "repo:r-devel/r-svn is:pr author:%s",
      login
    )
    # Do not cache the search result: additional PRs may be merged later in
    # the same quarter. Individual PR details are cached below.
    search <- github_request("search/issues", list(q = q, per_page = 100), 
                             key = NULL)
    prs <- search$items %||% list()
    for (pr in prs) {
      repo <- sub("^https://api.github.com/repos/", "", 
                  pr$repository_url %||% "")
      repo_key <- gsub("/", "-", repo)
      if (!nzchar(repo)) next
      number <- pr$number
      details <- github_request(
        sprintf("repos/%s/pulls/%s", repo, number),
        key = sprintf("pr-%s-%s", repo_key, number)
      )
      # merged PRs relate to GitHub mirror
      if (!is.null(details$merged_at)) next
      if (!in_period(details$closed_at)) next
      comments <- github_request(
        sprintf("repos/%s/issues/%s/comments", repo, number),
        key = NULL
      )
      commits <- github_request(
        sprintf("repos/%s/pulls/%s/commits", repo, number),
        list(per_page = 100),
        sprintf("pr-commits-%s-%s", repo_key, number)
      )
      texts <- c(
        pr$title %||% "",
        pr$body %||% "",
        vapply(comments, function(x) x$body %||% "", character(1)),
        vapply(commits, function(x) x$commit$message %||% "", character(1))
      )
      if (has_bugzilla_title(pr$title %||% "")) next
      if (has_bugzilla_link(texts)) next
      revisions <- unique(unlist(lapply(texts, svn_revisions), 
                                 use.names = FALSE))
      core_comment <- any(vapply(comments,
                                 function(x) x$user$login %in% CORE_GITHUB,
                                 logical(1)))
      evidence <- if (length(revisions)) {
        paste("Closed PR references", paste(revisions, collapse = ", ")) 
      } else if (core_comment) {
        "Closed PR with core developer comment; no SVN revision reference found" 
      } else "Closed PR (no SVN revision reference found)"
      commit_urls <- if (length(revisions)) {
        vapply(revisions, svn_commit_url, character(1)) 
      } else character()
      n <- n + 1L
      rows[[n]] <- tibble(
        contributor = full_name(login, GITHUB_USERS), login = login,
        bug_id = NA_integer_, bugzilla_url = "",
        date = format(uk_time(details$closed_at), "%Y-%m-%d %H:%M:%S", 
                      tz = "Europe/London"),
        evidence_url = details$html_url %||% pr$html_url,
        evidence = paste0(repo, "#", number, ": ", pr$title %||% "", ". ", 
                          evidence),
        source = "GitHub pull request", patch_date = NA_character_,
        svn_revisions = paste(revisions, collapse = ", "),
        commit_urls = paste(commit_urls[nzchar(commit_urls)], collapse = ", "),
        svn_comment_urls = "",
        confirmation = if (length(revisions)) "Yes" else "Uncertain",
        notes = if (length(revisions)) "" else {
          paste("Check whether this PR resulted in an applied R commit")
        }
      )
    }
  }
  if (length(rows)) bind_rows(rows) else tibble()
}
