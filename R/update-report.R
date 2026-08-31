source("R/common.R")

args <- commandArgs(trailingOnly = TRUE)
data_root <- if (length(args) > 0) args[[1]] else "bug-stats"

bugs_dir <- find_data_dir(data_root, "bugs")
bugs <- parse_all_bugs(bugs_dir)
dump_date <- dump_updated(bugs)

message("Parsed ", length(bugs), " bug XML files.")

triaged_bugs <- keep(bugs, ~ identical(.x$status, "TRIAGED"))

message("Current TRIAGED bugs: ", length(triaged_bugs))

dir.create("data", showWarnings = FALSE, recursive = TRUE)

triaged <- classify_triaged(
  triaged_bugs,
  cache_path = "data/ai-cache.csv",
  prompt_path = "prompts/classify-triaged-bug.md"
) |>
  arrange(factor(category, levels = TRIAGE_CATEGORIES), last_comment, bug_id)

patches <- additional_team_patches(bugs) |>
  arrange(component, patch_date, bug_id)

write_csv(triaged, "data/triaged-bugs.csv")
write_csv(patches, "data/team-patches.csv")

write_readme(triaged, patches, dump_date)
