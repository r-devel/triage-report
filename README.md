# Current TRIAGED bugs and patches from Triage Team

_Automatically generated from the R Bugzilla dump updated 2026-10-30._

## Triaged bugs

_Dates show the most recent triager comment on the bug._
_Core developers in CC should not be assumed responsible for action._

### Major patches

* [Bug 18495](https://bugs.r-project.org/show_bug.cgi?id=18495) — Alternative algorithm for `which()` (2026-06-26, in CC: maechler)

### Minor patches

* [Bug 18258](https://bugs.r-project.org/show_bug.cgi?id=18258) — 'trace' only half-works for generated functions in packages (2025-09-02)
* [Bug 16135](https://bugs.r-project.org/show_bug.cgi?id=16135) — error in: convolve( 1:5, 1, type='filter') (2026-02-20, in CC: maechler)
* [Bug 19074](https://bugs.r-project.org/show_bug.cgi?id=19074) — parallel::makeCluster(<cluster>, type = "PSOCK") does not give an error (2026-05-19)
* [Bug 19163](https://bugs.r-project.org/show_bug.cgi?id=19163) — axis() throws error and plot() runs out of memory when repeated many times (> 1000 plots) (2026-09-12)
* [Bug 18911](https://bugs.r-project.org/show_bug.cgi?id=18911) — cleanup tcltk (2026-09-19)
* [Bug 19098](https://bugs.r-project.org/show_bug.cgi?id=19098) — Ctrl-D does not exit R console on Windows (2026-09-22, in CC: tierney)

### Recommended closures

_None._

### Needs more information

_None._

### Needs core developer discussion

* [Bug 17928](https://bugs.r-project.org/show_bug.cgi?id=17928) — NextMethod does not appear to dispatch to group generic methods from specific methods. (2026-04-08)
* [Bug 17702](https://bugs.r-project.org/show_bug.cgi?id=17702) — Assignment to data.frame column (`$<-` or `[[<-`) should convert POSIXlt to POSIXct (2026-04-13, in CC: turner)

## Additional Triage Team patches awaiting review

_Dates show when the patch was submitted._
_Core developers in CC should not be assumed responsible for action._

### P1

These patches address critical issues and require attention from R Core as soon as possible, ahead of other R project work.

_None._

### P2

These are the most important or urgent regular patches from the Triage Team and should be prioritised before others below.

#### Low-level

* [Bug 19252](https://bugs.r-project.org/show_bug.cgi?id=19252) — compiler::compile() segfaults on break in complex assignment (2026-10-28, in CC: tierney)
* [Bug 19111](https://bugs.r-project.org/show_bug.cgi?id=19111) — `EnlargeVector()` allocates while the freshly coerced LHS is unprotected (`options(check.bounds = TRUE)`) (2026-10-29)

#### Windows GUI / Window specific

* [Bug 19198](https://bugs.r-project.org/show_bug.cgi?id=19198) — Rprof(NULL) on Windows closes the profile file and handles while the sampling thread may still be writing (2026-10-01)

#### Wishlist

* [Bug 18995](https://bugs.r-project.org/show_bug.cgi?id=18995) — tre-parse.c has a variety of out-of-bounds reads (2026-10-30)

### P3

These Triage Team patches should be looked at next.

#### Low-level

* [Bug 19051](https://bugs.r-project.org/show_bug.cgi?id=19051) — casts from double to R_xlen_t can trigger undefined behaviour (2026-04-14)
* [Bug 19119](https://bugs.r-project.org/show_bug.cgi?id=19119) — `writeChar()` on Windows counts supplementary characters twice (2026-08-03)
* [Bug 19158](https://bugs.r-project.org/show_bug.cgi?id=19158) — env.profile() reports a wrong number of chains; hashed environments count bindings and occupied chains inconsistently (2026-09-04)
* [Bug 19227](https://bugs.r-project.org/show_bug.cgi?id=19227) — Numeric ALTREP Elt/Get_region methods run with GC enabled: document that they must not allocate, or suspend GC (2026-10-16)
* [Bug 19050](https://bugs.r-project.org/show_bug.cgi?id=19050) — float-to-int overflow in R parser (2026-10-30)

#### S4methods

* [Bug 19244](https://bugs.r-project.org/show_bug.cgi?id=19244) — setRefClass(): avoidable costs in method processing and object creation; $methods(name = NULL) fails to remove a method (2026-10-23)

#### Windows GUI / Window specific

* [Bug 19143](https://bugs.r-project.org/show_bug.cgi?id=19143) — `Sys.getlocale()` does not mark non-ASCII Windows locale names as UTF-8 (2026-08-28)
* [Bug 19103](https://bugs.r-project.org/show_bug.cgi?id=19103) — choose.dir() returns NA without showing a dialog in Rterm/Rscript (2026-10-30)

### P4

These Triage Team patches can wait their turn.

#### I/O

* [Bug 19129](https://bugs.r-project.org/show_bug.cgi?id=19129) — Rf_EncodeString sometimes over-counts double quotes (2026-08-07)
* [Bug 19208](https://bugs.r-project.org/show_bug.cgi?id=19208) — readLines() leaks its line buffer when an error unwinds mid-read (2026-10-09, in CC: tierney)

#### Low-level

* [Bug 18353](https://bugs.r-project.org/show_bug.cgi?id=18353) — assigning to hashtab via $<- 'corrupts' table (2025-09-12)
* [Bug 19025](https://bugs.r-project.org/show_bug.cgi?id=19025) — Provide tool for manipulating order of objects on search path (2026-03-23)
* [Bug 19026](https://bugs.r-project.org/show_bug.cgi?id=19026) — Proposal for embedding API managing debugger state (2026-03-23)
* [Bug 19031](https://bugs.r-project.org/show_bug.cgi?id=19031) — patch: implement fast path for |, & in byte code evaluator (2026-03-27)
* [Bug 19032](https://bugs.r-project.org/show_bug.cgi?id=19032) — SETVAR does not prime the smallcache binding cache (2026-03-27)
* [Bug 19024](https://bugs.r-project.org/show_bug.cgi?id=19024) — Add R_mapEnv as internal C helper for iterating over environment values (2026-03-31, in CC: tierney)
* [Bug 19114](https://bugs.r-project.org/show_bug.cgi?id=19114) — poison free small-node data to catch use of collected objects (2026-08-01)
* [Bug 19123](https://bugs.r-project.org/show_bug.cgi?id=19123) — Memory leak in `scan()` when a field fails type conversion (2026-08-04)
* [Bug 19157](https://bugs.r-project.org/show_bug.cgi?id=19157) — unserialize() leaks the CHARSXP read buffer when the stream errors mid-string (2026-09-03)
* [Bug 19209](https://bugs.r-project.org/show_bug.cgi?id=19209) — R_realloc(): resizable R_alloc()-style transient memory that preserves vmaxget() marks (2026-10-09)
* [Bug 19008](https://bugs.r-project.org/show_bug.cgi?id=19008) — on.exit() at top level is a silent no-op (2026-10-29, in CC: tierney)

#### Mac GUI / Mac specific

* [Bug 19092](https://bugs.r-project.org/show_bug.cgi?id=19092) — `R CMD config --ldflags` is incomplete for `--enable-R-static-lib` on macOS (2026-06-23)

#### Wishlist

* [Bug 18039](https://bugs.r-project.org/show_bug.cgi?id=18039) — Wishlist: allow Sys.setenv() to accept named vector (2021-01-27)
* [Bug 19028](https://bugs.r-project.org/show_bug.cgi?id=19028) — Should object.size() be ALTREP aware? (2026-03-24)
* [Bug 19030](https://bugs.r-project.org/show_bug.cgi?id=19030) — Enable constant folding of paste / paste0? (2026-03-26)
* [Bug 19042](https://bugs.r-project.org/show_bug.cgi?id=19042) — Provide getDLLVersion on all platforms? (2026-04-02)
* [Bug 19141](https://bugs.r-project.org/show_bug.cgi?id=19141) — `is.na()` and the `as.*()` coercions read their argument one element at a time (2026-09-03)
* [Bug 19159](https://bugs.r-project.org/show_bug.cgi?id=19159) — hashed environments: grow the hash table at 0.75 bindings per chain, to prime sizes that suit the PJW hash (2026-09-04)

### P5

These patches have not yet been prioritised.

#### Documentation

* [Bug 18705](https://bugs.r-project.org/show_bug.cgi?id=18705) — Document (lack of) include.only= behavior under "reattachment", and suggested workaround (2024-04-16)

#### Language

* [Bug 18583](https://bugs.r-project.org/show_bug.cgi?id=18583) — cbind.ts does not respect 'deparse.level' (2024-02-08, in CC: maechler)

#### Low-level

* [Bug 18096](https://bugs.r-project.org/show_bug.cgi?id=18096) — [patch] sort() did not return ALTREP for already increasing int vectors (2021-05-06)
* [Bug 18863](https://bugs.r-project.org/show_bug.cgi?id=18863) — Add source locations to parser warnings (2025-02-26)
* [Bug 19096](https://bugs.r-project.org/show_bug.cgi?id=19096) — Update handling of overflow in integer operations (2026-06-30)
* [Bug 19125](https://bugs.r-project.org/show_bug.cgi?id=19125) — Integer arithmetic means '%z' for minute-level offsets is incorrect (2026-08-04)
* [Bug 19145](https://bugs.r-project.org/show_bug.cgi?id=19145) — MSan issue in context.c reading uninitialized state (2026-09-01)
* [Bug 19259](https://bugs.r-project.org/show_bug.cgi?id=19259) — Lazy-load DB is too small (100 slots for .rdb vs. >600 for DLLs) (2026-10-27)

#### Misc

* [Bug 18938](https://bugs.r-project.org/show_bug.cgi?id=18938) — seq.Date inconsistent on whether to= can be a string (2025-08-21)
* [Bug 18958](https://bugs.r-project.org/show_bug.cgi?id=18958) — 'methods_message' component of 'check_packages_used' internal class should be character(), not "", when empty (2025-10-16)

#### S4methods

* [Bug 18833](https://bugs.r-project.org/show_bug.cgi?id=18833) — methods:::.identicalGeneric can wrongly ignore differences in default values of formal arguments (2024-12-07)
* [Bug 19079](https://bugs.r-project.org/show_bug.cgi?id=19079) — S4 packages with group methods error with "subscript out of bounds" under unloadNamespace with Imports: methods (2026-05-29, in CC: lawrence)
* [Bug 19083](https://bugs.r-project.org/show_bug.cgi?id=19083) — setGeneric("f", \(x) { standardGeneric("x") }) makes generic with class 'nonstandardGenericFunction' (2026-06-22, in CC: maechler)
* [Bug 19237](https://bugs.r-project.org/show_bug.cgi?id=19237) — .updateMethodsInTable for group generics inefficiently over-checks signatures (up and down groups) (2026-10-21)
* [Bug 19239](https://bugs.r-project.org/show_bug.cgi?id=19239) — Add fast paths for quadratic loop in .resetInheritedMethods (2026-10-21)
* [Bug 19246](https://bugs.r-project.org/show_bug.cgi?id=19246) — typo in .recacheSubclasses -- wrong inheritance is checked in class unions (2026-10-24)
* [Bug 19248](https://bugs.r-project.org/show_bug.cgi?id=19248) — getClassDef(where=<character>) stopped working (2026-10-26)
* [Bug 19249](https://bugs.r-project.org/show_bug.cgi?id=19249) — Use getClassDef itself to avoid implicitly calling it twice isClass (2026-10-26)
* [Bug 19254](https://bugs.r-project.org/show_bug.cgi?id=19254) — Add fast paths for early exit from is() (2026-10-26)
* [Bug 19257](https://bugs.r-project.org/show_bug.cgi?id=19257) — Pick S4 methods' internal environments' parents intentionally to avoid very large storage/startup costs (2026-10-27)

#### Translations

* [Bug 18025](https://bugs.r-project.org/show_bug.cgi?id=18025) — xgettext/xngettext miss messages when supplied with qualified namespace (2021-01-04)
* [Bug 17819](https://bugs.r-project.org/show_bug.cgi?id=17819) — Translate untranslated char arrays in all library packages (2023-09-01, in CC: lawrence)
* [Bug 17957](https://bugs.r-project.org/show_bug.cgi?id=17957) — Missing translations of some messages (2023-09-10, in CC: maechler)
* [Bug 18793](https://bugs.r-project.org/show_bug.cgi?id=18793) — checkPoFile() has a really strong assumption of no blank lines between msgid and msgstr entries (2024-09-09)
* [Bug 18091](https://bugs.r-project.org/show_bug.cgi?id=18091) — tools::xgettext fails on a wrapper of a gettextf (2024-09-14)

#### Wishlist

* [Bug 17676](https://bugs.r-project.org/show_bug.cgi?id=17676) — vcov.lm should calculate vcov more directly for efficiency (2019-12-17)
* [Bug 17778](https://bugs.r-project.org/show_bug.cgi?id=17778) — barplot should take user-supplied lwd (2020-05-01)
* [Bug 17918](https://bugs.r-project.org/show_bug.cgi?id=17918) — Improve debugcall and debugcallonce to support calls to funs via :: :::, patch included (2020-09-08)
* [Bug 18407](https://bugs.r-project.org/show_bug.cgi?id=18407) — Underscore-separated numeric literals (2022-09-20)
* [Bug 18700](https://bugs.r-project.org/show_bug.cgi?id=18700) — Error passing improvements in 'parallel' (2024-04-23)
* [Bug 18883](https://bugs.r-project.org/show_bug.cgi?id=18883) — Wish: resize the input width in Rterm.exe (2025-04-15)
* [Bug 19004](https://bugs.r-project.org/show_bug.cgi?id=19004) — Package version: keep formatting (2026-02-14)
* [Bug 19105](https://bugs.r-project.org/show_bug.cgi?id=19105) — Provide a traceback when crashing on Windows (2026-07-19)

## About this report

This report is generated automatically from R Bugzilla data. The classification of TRIAGED bugs is generated with assistance from generative AI to support human review. Priorities for additional patches are based on Bugzilla Importance, assigned by triagers.

The code for this project has been developed with substantial assistance from generative AI. The maintainers review and test generated code before it is incorporated into the repository.

