# Private Notes final-pass checklist

Review against upstream main 87d28a2 on October 10, 2026.

- P1: DataNukeRunner must delete EpisodeNoteRecord; test both note types.
- P1: Episode identity reconciliation must migrate notes and resolve collisions without losing text or duplicating whole-episode notes.
- P1: Register all new UI tests in scripts/ui-test-shards.txt; run the manifest check.
- P2: Protect hidden drafts when switching scope. Planned resolution: separate actions before opening the editor, remove the scope toggle.
- Pass the real episode title to edit sheets.
- Consolidate duplicated update/save/restore logic in EpisodeNoteStore.
- Test failed note create/edit saves, UI Save/Cancel/dismiss playback wiring, and existing on-disk schema upgrades.
- Remove obvious marker comments; retain the playback-session comment about SwiftUI dismissal ordering.
- Bring feature branch up to date with upstream and validate integration.
