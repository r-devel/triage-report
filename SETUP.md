# Prototype setup

This repository generates a daily report from the R Bugzilla dump and can
email a plain-text version once a month.

No licence is specified for the prototype at present.

## Repository settings

In **Settings > Secrets and variables > Actions**, add the following.

### Daily report

Repository variable:

- `GEMINI_MODEL`: optional; defaults to `gemini-3.5-flash-lite`.

Repository secret:

- `BUG_STATS_URL`: URL of the daily `bug-stats.tar.gz` dump.
- `GEMINI_API_KEY`: Gemini API key.

The Gemini model is deliberately configurable. The rest of the reporting
workflow does not depend on a particular AI provider, although the prototype
currently implements Gemini.

## Monthly email

The monthly email workflow is independent of the AI call. It reads the CSVs
already committed to the repository.

Repository secrets:

- `EMAIL_TO`
- `EMAIL_FROM` (optional; defaults to the SMTP username)
- `SMTP_HOST`
- `SMTP_PORT` (optional; defaults to `587`)
- `SMTP_USERNAME`
- `SMTP_PASSWORD`

For initial testing, set `EMAIL_TO` to your own address and run the
`Email monthly triage report` workflow manually from the Actions tab.

## Report rules

### Triaged bugs

The first list contains bugs whose current Bugzilla status is exactly
`TRIAGED`.

AI classification is cached using a hash of the Bugzilla material supplied to
the model. An unchanged TRIAGED bug therefore reuses its previous
classification. A bug that is no longer TRIAGED simply drops out of the
report; it is not sent to the AI again.

Categories are:

- Major patches
- Minor patches
- Recommended closures
- Needs more information
- Needs core developer discussion

The generated README links each Bugzilla ID to the corresponding bug report.

### Additional Triage Team patches awaiting review

The second list contains open bugs that:

- were reported by a Triage Team member;
- do not currently have `TRIAGED` status; and
- have an attachment from a Triage Team member that looks like a patch.

Closed and resolved bugs are excluded. The list is grouped by Bugzilla
component.

Patch detection is deliberately conservative: attachment names/descriptions
containing `patch` or `diff`, or attachment contents resembling a unified/SVN
diff, are treated as patches. This heuristic should be checked against the
real dump before relying on the report.

## First run

Before enabling the schedule, use **Actions > Update triage report > Run
workflow**. Review:

- `README.md`
- `data/triaged-bugs.csv`
- `data/team-patches.csv`
- `data/ai-cache.csv`

The daily workflow runs at 06:17 UTC. The monthly email runs at 09:23 UTC on
the first day of each month. Both can also be run manually.

## Local test

With an extracted dump available at `bug-stats/`:

```sh
export GEMINI_API_KEY=...
export GEMINI_MODEL=gemini-3.5-flash-lite
Rscript R/update-report.R bug-stats
```

To generate the email without sending it:

```sh
Rscript R/render-email.R
cat monthly-email.txt
```
