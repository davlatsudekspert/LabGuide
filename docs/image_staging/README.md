# Commons photo candidates: staging queue (metadata only)

Status: STAGED_NEEDS_EXPERT_ID. Nothing here is shipped, bundled or shown in the app;
no binary was downloaded. This is the ready-to-go queue for when the owner's experts approve.

- Source of the candidate list: owner package `67_MANBA_TO_LIQ_REESTR.csv`, rows with group
  `additional_31` (31 files; the 24 earlier atlas rows, the 8 HOLD sources and the 12 equipment
  addendum rows are out of scope here).
- Live check: MediaWiki API (`action=query`, `imageinfo` + `extmetadata`, `revisions`,
  `templates`, `categories`) at the capture date in the JSON (2026-10-24), descriptive
  User-Agent, serialised requests with back-off on HTTP 429.
- File: `commons_candidates.json`. Per item: registry id, file title, page URL, `claim` (registry),
  `live` (licence, licence URL, author text, credit, revision id and timestamp, sha1, size,
  dimensions, restrictions, templates), `matches_claim`, `nc_nd`, `target_proposed`,
  `scientific_reference_present` (false for all: the registry gives none), `hold_reason`
  (none in this group), `status`, `capture_date`, notes.

## Result

| Count | Meaning |
|---|---|
| 31 | candidates checked |
| 31 | STAGED_NEEDS_EXPERT_ID (live licence equals claim; no NC/ND; no restriction/permission template) |
| 0 | REJECTED (licence differs or NC/ND) |

Licences: 27 x CC BY-SA 4.0, 4 x CC BY-SA 3.0 (all allowed by the app image guard).
Two rows (LG26X-037, LG26X-051) had the registry author placeholder `CHECK_ON_FILE_PAGE`;
the live author is recorded and the licence matches.

## Before any item may be used

1. A histology / cytology / haematology / parasitology specialist confirms the identification
   (morphology) and the target section; a citable scientific reference is added.
2. The owner re-confirms licence, author and revision at that moment (Commons files can change).
3. Download the original, record sha256, resize with a "changes made" note, add credit
   (author, licence, link, ShareAlike note), then add through the existing image guards.
4. Special cases: LMC-3000 centrifuges (not catalog models), the two Servier/SVG drawings
   (illustrations, not micrographs), Calicut Medical College PAP (institutional specimen).

Do not add the existing 65 micrographs or the 3 quiz-excluded images from this queue; atlas
magnification stays unknown where unknown.
