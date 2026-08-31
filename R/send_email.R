library(curl)

body <- readLines("monthly-email.txt", warn = FALSE, encoding = "UTF-8")

from <- Sys.getenv("EMAIL_FROM")
to <- Sys.getenv("EMAIL_TO")

message <- c(
  paste0("From: ", from),
  paste0("To: ", to),
  "Subject: Current TRIAGED bugs and patches from Triage Team",
  "Content-Type: text/plain; charset=UTF-8",
  "",
  body
)

handle <- new_handle(
  username = Sys.getenv("SMTP_USERNAME"),
  password = Sys.getenv("SMTP_PASSWORD"),
  mail_from = from,
  mail_rcpt = to,
  upload = TRUE,
  readfunction = charToRaw(paste(message, collapse = "\r\n"))
)

smtp_url <- paste0(
  "smtp://",
  Sys.getenv("SMTP_HOST"),
  ":",
  Sys.getenv("SMTP_PORT", "587")
)

handle_setopt(handle, use_ssl = 1)
curl_fetch_memory(smtp_url, handle = handle)