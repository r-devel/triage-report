# Current TRIAGED bugs and patches from Triage Team

_Automatically generated from the R Bugzilla dump updated 2026-10-04._

## Triaged bugs

_Dates show the most recent triager comment on the bug._

### Major patches

* [Bug 18495](https://bugs.r-project.org/show_bug.cgi?id=18495) — Alternative algorithm for `which()` (2026-06-26)

### Minor patches

* [Bug 18258](https://bugs.r-project.org/show_bug.cgi?id=18258) — 'trace' only half-works for generated functions in packages (2025-09-02)
* [Bug 16135](https://bugs.r-project.org/show_bug.cgi?id=16135) — error in: convolve( 1:5, 1, type='filter') (2026-02-20)
* [Bug 19074](https://bugs.r-project.org/show_bug.cgi?id=19074) — parallel::makeCluster(<cluster>, type = "PSOCK") does not give an error (2026-05-19)
* [Bug 19163](https://bugs.r-project.org/show_bug.cgi?id=19163) — axis() throws error and plot() runs out of memory when repeated many times (> 1000 plots) (2026-09-12)
* [Bug 18911](https://bugs.r-project.org/show_bug.cgi?id=18911) — cleanup tcltk (2026-09-19)
* [Bug 19098](https://bugs.r-project.org/show_bug.cgi?id=19098) — Ctrl-D does not exit R console on Windows (2026-09-22)

### Recommended closures

_None._

### Needs more information

_None._

### Needs core developer discussion

* [Bug 10455](https://bugs.r-project.org/show_bug.cgi?id=10455) — Bug in pacf -- Proposed patch (2026-03-06)
* [Bug 17928](https://bugs.r-project.org/show_bug.cgi?id=17928) — NextMethod does not appear to dispatch to group generic methods from specific methods. (2026-04-08)
* [Bug 17702](https://bugs.r-project.org/show_bug.cgi?id=17702) — Assignment to data.frame column (`$<-` or `[[<-`) should convert POSIXlt to POSIXct (2026-04-13)

## Additional Triage Team patches awaiting review

_Dates show when the patch was submitted._

### Documentation

* [Bug 18705](https://bugs.r-project.org/show_bug.cgi?id=18705) — Document (lack of) include.only= behavior under "reattachment", and suggested workaround (2024-04-16)

### I/O

* [Bug 19129](https://bugs.r-project.org/show_bug.cgi?id=19129) — Rf_EncodeString sometimes over-counts double quotes (2026-08-07)
* [Bug 19194](https://bugs.r-project.org/show_bug.cgi?id=19194) — read.dcf() adds a duplicate column for every repeat of a field name containing invalid UTF-8 (regression from r90200) (2026-10-01)
* [Bug 19200](https://bugs.r-project.org/show_bug.cgi?id=19200) — memDecompress(type = "gzip") loops forever on a truncated gzip/zlib stream (builds without libdeflate) (2026-10-03)

### Language

* [Bug 18583](https://bugs.r-project.org/show_bug.cgi?id=18583) — cbind.ts does not respect 'deparse.level' (2024-02-08)

### Low-level

* [Bug 18096](https://bugs.r-project.org/show_bug.cgi?id=18096) — [patch] sort() did not return ALTREP for already increasing int vectors (2021-05-06)
* [Bug 18863](https://bugs.r-project.org/show_bug.cgi?id=18863) — Add source locations to parser warnings (2025-02-26)
* [Bug 18353](https://bugs.r-project.org/show_bug.cgi?id=18353) — assigning to hashtab via $<- 'corrupts' table (2025-09-12)
* [Bug 19025](https://bugs.r-project.org/show_bug.cgi?id=19025) — Provide tool for manipulating order of objects on search path (2026-03-23)
* [Bug 19026](https://bugs.r-project.org/show_bug.cgi?id=19026) — Proposal for embedding API managing debugger state (2026-03-23)
* [Bug 19031](https://bugs.r-project.org/show_bug.cgi?id=19031) — patch: implement fast path for |, & in byte code evaluator (2026-03-27)
* [Bug 19032](https://bugs.r-project.org/show_bug.cgi?id=19032) — SETVAR does not prime the smallcache binding cache (2026-03-27)
* [Bug 19024](https://bugs.r-project.org/show_bug.cgi?id=19024) — Add R_mapEnv as internal C helper for iterating over environment values (2026-03-31)
* [Bug 19050](https://bugs.r-project.org/show_bug.cgi?id=19050) — float-to-int overflow in R parser (2026-04-13)
* [Bug 19051](https://bugs.r-project.org/show_bug.cgi?id=19051) — casts from double to R_xlen_t can trigger undefined behaviour (2026-04-14)
* [Bug 19063](https://bugs.r-project.org/show_bug.cgi?id=19063) — truncate overly-long paths in dir.create() (2026-04-27)
* [Bug 19066](https://bugs.r-project.org/show_bug.cgi?id=19066) — Provide a more explicit error message for array(dim = NA) (2026-04-29)
* [Bug 19096](https://bugs.r-project.org/show_bug.cgi?id=19096) — Update handling of overflow in integer operations (2026-06-30)
* [Bug 19114](https://bugs.r-project.org/show_bug.cgi?id=19114) — poison free small-node data to catch use of collected objects (2026-08-01)
* [Bug 19116](https://bugs.r-project.org/show_bug.cgi?id=19116) — <matrix>[[i, j]]: stochastic error with negative i (2026-08-02)
* [Bug 19119](https://bugs.r-project.org/show_bug.cgi?id=19119) — `writeChar()` on Windows counts supplementary characters twice (2026-08-03)
* [Bug 19123](https://bugs.r-project.org/show_bug.cgi?id=19123) — Memory leak in `scan()` when a field fails type conversion (2026-08-04)
* [Bug 19125](https://bugs.r-project.org/show_bug.cgi?id=19125) — Integer arithmetic means '%z' for minute-level offsets is incorrect (2026-08-04)
* [Bug 19145](https://bugs.r-project.org/show_bug.cgi?id=19145) — MSan issue in context.c reading uninitialized state (2026-09-01)
* [Bug 19157](https://bugs.r-project.org/show_bug.cgi?id=19157) — unserialize() leaks the CHARSXP read buffer when the stream errors mid-string (2026-09-03)
* [Bug 19158](https://bugs.r-project.org/show_bug.cgi?id=19158) — env.profile() reports a wrong number of chains; hashed environments count bindings and occupied chains inconsistently (2026-09-04)
* [Bug 19161](https://bugs.r-project.org/show_bug.cgi?id=19161) — unserialize() leaks its iconv conversion descriptors when an error unwinds mid-stream (2026-09-06)
* [Bug 19183](https://bugs.r-project.org/show_bug.cgi?id=19183) — read.dcf() leaks its line buffer and compiled regexps when it signals an error on malformed input (2026-09-26)
* [Bug 19184](https://bugs.r-project.org/show_bug.cgi?id=19184) — parse_Rd() leaks the parser stack and macro pushback buffer when an error is raised while parsing (2026-09-26)

### Mac GUI / Mac specific

* [Bug 19092](https://bugs.r-project.org/show_bug.cgi?id=19092) — `R CMD config --ldflags` is incomplete for `--enable-R-static-lib` on macOS (2026-06-23)

### Misc

* [Bug 18938](https://bugs.r-project.org/show_bug.cgi?id=18938) — seq.Date inconsistent on whether to= can be a string (2025-08-21)
* [Bug 18958](https://bugs.r-project.org/show_bug.cgi?id=18958) — 'methods_message' component of 'check_packages_used' internal class should be character(), not "", when empty (2025-10-16)
* [Bug 19156](https://bugs.r-project.org/show_bug.cgi?id=19156) — MASS, boot are Suggests for parallel (2026-09-03)

### S4methods

* [Bug 18833](https://bugs.r-project.org/show_bug.cgi?id=18833) — methods:::.identicalGeneric can wrongly ignore differences in default values of formal arguments (2024-12-07)
* [Bug 19079](https://bugs.r-project.org/show_bug.cgi?id=19079) — S4 packages with group methods error with "subscript out of bounds" under unloadNamespace with Imports: methods (2026-05-29)
* [Bug 19083](https://bugs.r-project.org/show_bug.cgi?id=19083) — setGeneric("f", \(x) { standardGeneric("x") }) makes generic with class 'nonstandardGenericFunction' (2026-06-22)

### Translations

* [Bug 18025](https://bugs.r-project.org/show_bug.cgi?id=18025) — xgettext/xngettext miss messages when supplied with qualified namespace (2021-01-04)
* [Bug 17819](https://bugs.r-project.org/show_bug.cgi?id=17819) — Translate untranslated char arrays in all library packages (2023-09-01)
* [Bug 17957](https://bugs.r-project.org/show_bug.cgi?id=17957) — Missing translations of some messages (2023-09-10)
* [Bug 18793](https://bugs.r-project.org/show_bug.cgi?id=18793) — checkPoFile() has a really strong assumption of no blank lines between msgid and msgstr entries (2024-09-09)
* [Bug 18091](https://bugs.r-project.org/show_bug.cgi?id=18091) — tools::xgettext fails on a wrapper of a gettextf (2024-09-14)

### Windows GUI / Window specific

* [Bug 19143](https://bugs.r-project.org/show_bug.cgi?id=19143) — `Sys.getlocale()` does not mark non-ASCII Windows locale names as UTF-8 (2026-08-28)
* [Bug 19198](https://bugs.r-project.org/show_bug.cgi?id=19198) — Rprof(NULL) on Windows closes the profile file and handles while the sampling thread may still be writing (2026-10-01)

### Wishlist

* [Bug 17676](https://bugs.r-project.org/show_bug.cgi?id=17676) — vcov.lm should calculate vcov more directly for efficiency (2019-12-17)
* [Bug 17778](https://bugs.r-project.org/show_bug.cgi?id=17778) — barplot should take user-supplied lwd (2020-05-01)
* [Bug 17918](https://bugs.r-project.org/show_bug.cgi?id=17918) — Improve debugcall and debugcallonce to support calls to funs via :: :::, patch included (2020-09-08)
* [Bug 18039](https://bugs.r-project.org/show_bug.cgi?id=18039) — Wishlist: allow Sys.setenv() to accept named vector (2021-01-27)
* [Bug 18407](https://bugs.r-project.org/show_bug.cgi?id=18407) — Underscore-separated numeric literals (2022-09-20)
* [Bug 18700](https://bugs.r-project.org/show_bug.cgi?id=18700) — Error passing improvements in 'parallel' (2024-04-23)
* [Bug 18883](https://bugs.r-project.org/show_bug.cgi?id=18883) — Wish: resize the input width in Rterm.exe (2025-04-15)
* [Bug 18995](https://bugs.r-project.org/show_bug.cgi?id=18995) — tre-parse.c has a variety of out-of-bounds reads (2026-01-26)
* [Bug 19004](https://bugs.r-project.org/show_bug.cgi?id=19004) — Package version: keep formatting (2026-02-14)
* [Bug 19028](https://bugs.r-project.org/show_bug.cgi?id=19028) — Should object.size() be ALTREP aware? (2026-03-24)
* [Bug 19030](https://bugs.r-project.org/show_bug.cgi?id=19030) — Enable constant folding of paste / paste0? (2026-03-26)
* [Bug 19042](https://bugs.r-project.org/show_bug.cgi?id=19042) — Provide getDLLVersion on all platforms? (2026-04-02)
* [Bug 19105](https://bugs.r-project.org/show_bug.cgi?id=19105) — Provide a traceback when crashing on Windows (2026-07-19)
* [Bug 19141](https://bugs.r-project.org/show_bug.cgi?id=19141) — `is.na()` and the `as.*()` coercions read their argument one element at a time (2026-09-03)
* [Bug 19159](https://bugs.r-project.org/show_bug.cgi?id=19159) — hashed environments: grow the hash table at 0.75 bindings per chain, to prime sizes that suit the PJW hash (2026-09-04)
* [Bug 19197](https://bugs.r-project.org/show_bug.cgi?id=19197) — available.packages() speedups: zstd-compressed cache and faster R_version, duplicates, CRAN and subarch filters (2026-10-01)

## About this report

This report is generated automatically from R Bugzilla data. The classification of TRIAGED bugs is generated with the assistance of generative AI and should be treated as a summary to support, rather than replace, human review.

The code for this project has been developed with substantial assistance from generative AI. The maintainers review and test generated code before it is incorporated into the repository.

