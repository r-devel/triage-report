source("R/common.R")

triaged <- read_csv("data/triaged-bugs.csv", show_col_types = FALSE)

patches <- read_csv("data/team-patches.csv", show_col_types = FALSE)

readme_url <- Sys.getenv(
  "README_URL",
  "https://github.com/r-devel/triage-report"
)

write_plain_text_report(triaged, patches, readme_url)