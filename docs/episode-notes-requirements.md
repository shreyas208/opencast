# Private Notes requirements

Private Notes lets listeners save thoughts against an episode and its playback timestamp, review them, and return to those moments. These requirements consolidate the user requests through October 8, 2026; the behavior below supersedes conflicting details from the personal prototype.

Upstream discussion: [Episode notes issue and maintainer feedback](https://github.com/connlark/opencast/issues/17#issuecomment-6072550157).

## Naming

The user-facing feature name is **Private Notes**. This distinguishes listener-written notes from the app's existing **Show Notes** section for publisher-provided episode descriptions, while matching its concise title-case labels and verb-led actions.

| Surface | Label |
| --- | --- |
| Feature name and Playback settings section | Private Notes |
| Playback settings toggle | Show Note Buttons |
| Settings footer | Show note buttons in Now Playing. Saved notes are always available in episode details and the More Actions menu. Notes are stored on this device. |
| Now Playing create button and new editor title | Add Private Note |
| Existing note editor title | Edit Private Note |
| Creation menu choices | Add Timestamped Note, Add Episode Note |
| Export action inside Private Notes | Share Notes |
| Now Playing list button and notes pane title | Private Notes |
| Episode detail section heading when notes exist | Private Notes |
| Editor actions | Save, Cancel |
| Context menu action | Delete Note |
| Dedicated pane empty-state title | No Notes Yet |

Use “note” in ordinary explanatory prose. Keep internal model and store names based on **EpisodeNote** to describe their scope and avoid encoding UI wording into the data model. Use Private Notes consistently; describe device-local storage in supporting copy.

## Settings and visibility

- Add a persisted toggle in the Playback section of Settings that controls the visibility of notes-related buttons in Now Playing, including Add Note and Private Notes. Follow existing settings labels, storage, and layout conventions.
- Hiding those buttons must not delete notes.
- On the episode detail page (the “show page” in the requests), display notes whenever the episode has notes, regardless of the toggle.
- If an episode has no notes, its detail page must look as it does today: no notes heading, empty state, or empty notes pane.

## Adding notes

- Add Note on Now Playing opens a text editor with Save and Cancel.
- Capture the episode identity and playback timestamp when Add Note is tapped. The timestamp must not move while the listener types, and switching episodes must not attach the draft to the new episode.
- Pause playback when opening the editor if playback is active or requested, including loading or buffering.
- On Save, Cancel, or dismissal of an empty editor, resume only if opening the editor paused playback and the same episode is still loaded and paused. An episode that was already paused must remain paused.
- Save a nonempty note attached to that episode and timestamp. Trim surrounding whitespace and reject whitespace-only text.
- Persist notes across app launches. Device-local persistence is sufficient for this feature; cross-device sync has not been requested.
- A failed save must preserve the draft and display an error without dismissing the editor or resuming playback.
- Prevent accidental gesture dismissal of a nonempty draft; explicit Cancel discards it.

## Reviewing and seeking

- Place a Private Notes button beside Add Note or the existing Now Playing utility controls. It opens the current episode’s notes in timestamp order.
- Display each note’s timestamp and text. A timestamp action seeks to that point and starts playback; from the Now Playing Private Notes pane, it also closes the pane.
- Show note markers at their timestamps on the Now Playing progress bar. They must not intercept or interfere with scrubbing and must update when notes are added or deleted.
- Do not place markers against an invented duration when the episode’s duration is unknown or invalid.
- The dedicated notes pane already has a Private Notes title: do not repeat that heading or add a redundant wrapping card around the list.
- Each note may have its own rounded card. Its long-press preview must lift the entire card, including background and padding, rather than enlarging the text alone.
- Opening the dedicated Private Notes pane for an episode without notes may show an informative empty state. This does not apply to the episode detail page, where an empty section must be absent.

## Deleting notes

- Provide Delete Note through a native long-press context menu anchored to the individual note. This replaces the prototype’s trash button and list-wide confirmation popup.
- Provide an equivalent accessible deletion action.
- Delete only the selected note, persist the deletion, and update the note list and timeline markers.
- Display an error if deletion fails.

## Public repository conventions

- Follow CONTRIBUTING.md: Swift 6, strict concurrency, SwiftUI, Observation, small single-purpose files, and no new third-party dependencies.
- Use the public repository’s existing persistence, settings, playback, presentation, visual styling, and accessibility conventions. The personal prototype is a behavioral reference, not a requirement to retain its implementation.
- Keep the upstream PR focused on episode notes. Personal bundle identifiers, signing-team settings, capability removals, and device-only CloudKit disablements belong in the ignored local device build overlay, not in the feature branch.
- Work on episode-notes in the fork and eventually target connlark/opencast main. Keep fork main aligned with upstream main.
- Test persistence, episode isolation, deletion, playback pause/resume behavior, settings visibility, conditional detail-page rendering, and marker placement with appropriate focused tests. Validate the interactions on device.

## Visibility decisions

The Playback toggle defaults to off. It controls only Add Note and Private Notes buttons; saved notes and their timeline markers remain visible independently of that toggle.

## Whole-episode note

- Each episode may also have one non-timestamped Episode Note, alongside its timestamped notes.
- Add Note offers This Moment and Whole Episode. Whole Episode loads the existing note; Save creates or updates that single note.
- Show the Episode Note first in Private Notes and episode details. Provide Edit Note and Delete Note; editing from the list does not change playback.
- Whole-episode notes have no seek action or timeline marker. Existing timestamped notes retain their behavior.

## Updated interaction requirements (October 10)

- Playback Add Note and Private Notes are icon-only circular utility controls, retaining accessible labels.
- Add Note opens a menu with Timestamped Note and Episode Note before editing; remove the in-editor scope toggle.
- Editor titles are Add Private Note and Edit Private Note. Existing whole-episode notes load as edits.
- The playback three-dot menu always includes Private Notes, even with note buttons hidden.
- Playback Private Notes uses a trailing Share Notes icon instead of Done, with swipe and accessibility escape dismissal.
- Both the playback pane and episode detail notes section export plain text using the standard share sheet, including Apple Notes. Order: episode title, show name, whole-episode text if any, timestamped notes in chronological order.
- Episode Actions includes Add Episode Note as the last item before the download/transcript section. It supports whole-episode notes only, regardless of the note-buttons setting, without changing playback.
- Settings Delete Data includes Delete All Private Notes with confirmation and failure reporting. Delete both note types for all episodes on this device, retaining other data.

## String consistency pass

Private Notes names the feature. Timestamped Note and Episode Note distinguish the two scopes. Use verb-led Add Timestamped Note and Add Episode Note choices. Use Add/Edit Private Note for editor titles and the creation icon’s accessible name; contextual Edit Note, Delete Note and Share Notes stay concise within Private Notes. Single-note failures use Couldn’t Save/Delete Private Note; bulk deletion uses Couldn’t Delete Private Notes. The editor field is Private Note for VoiceOver, and the whole-episode row is Edit Episode Note. Sentence-case confirmation: Delete all private notes?

The settings footer explains button visibility, alternate access, and device-local storage. The empty state points to both note types instead of assuming a timestamped note.
