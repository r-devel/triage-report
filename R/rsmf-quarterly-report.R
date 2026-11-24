# Compute RSMF metrics for last quarter
# If running manually download the latest Bugzilla dump first
# tar -xzf bug-stats.tar.gz

source("R/rsmf-metrics.R")

message("Reading Bugzilla dump from ", DATA_ROOT)
contribs_dir <- find_data_dir(DATA_ROOT, "contribs")
bugs_dir <- find_data_dir(DATA_ROOT, "bugs")
index <- read_contributor_index(contribs_dir)
message("Found ", nrow(index), 
        " contributor/bug pairs across seven contributors.")

# A bug changed before the period cannot have been reported, triaged, or closed
# during it. Keep bugs changed after the period too: they may have had a
# qualifying event during the period and changed again later.
index <- index |>
  filter(is.na(changeddate) | 
           as.Date(substr(changeddate, 1, 10)) >= as.Date(START_DATE))
if (!nrow(index)) {
  stop("No candidate bugs in contributor CSVs since the reporting-period start.")
}

bugs <- extract_bug_data(index, bugs_dir, END_DATE)
reported <- reported_rows(bugs)
triaged <- triaged_rows(bugs, index)
accepted_bugzilla <- accepted_bugzilla_rows(bugs)
accepted_prs <- github_pr_rows()
accepted <- bind_rows(accepted_bugzilla, accepted_prs)

# Stable, review-friendly schemas, even when a category is empty.
ensure_columns <- function(x, columns) {
  for (column in columns) if (!column %in% names(x)) x[[column]] <- NA_character_
  x[, columns]
}
common_cols <- c("contributor", "login", "bug_id", "bugzilla_url", "date", 
                 "evidence_url", "evidence", "source", "confirmation", "notes")
reported <- ensure_columns(reported, common_cols)
triaged <- ensure_columns(triaged, common_cols)
accepted <- ensure_columns(accepted, c(common_cols, "patch_date", 
                                       "svn_revisions", "commit_urls", 
                                       "svn_comment_urls"))

write_csv(reported |> arrange(contributor, date, bug_id), 
          file.path(OUTPUT_DIR, "bugs_reported.csv"), na = "")
write_csv(triaged |> arrange(contributor, date, bug_id), 
          file.path(OUTPUT_DIR, "bugs_triaged.csv"), na = "")
write_csv(accepted |> arrange(contributor, date, bug_id),
          file.path(OUTPUT_DIR, "patches_accepted.csv"), na = "")

# After manual review
reported <- read_csv(file.path(OUTPUT_DIR, "bugs_reported.csv"))
reported |> 
  count(confirmation)

triaged <- read_csv(file.path(OUTPUT_DIR, "bugs_triaged_reviewed.csv"))
triaged |> 
  count(confirmation)

accepted <- read_csv(file.path(OUTPUT_DIR, "patches_accepted_reviewed.csv"))
accepted |> 
  count(confirmation)