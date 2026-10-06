import SwiftData
import SwiftUI

struct EpisodeNotesSection: View {
    @Environment(\.modelContext) private var modelContext
    @State private var deletionError: String?
    @Query private var notes: [EpisodeNoteRecord]
    let showsHeading: Bool
    let onSeek: (TimeInterval) -> Void

    init(episodeID: String, showsHeading: Bool = true, onSeek: @escaping (TimeInterval) -> Void) {
        let id = episodeID
        _notes = Query(
            filter: #Predicate<EpisodeNoteRecord> { $0.episodeID == id },
            sort: [SortDescriptor(\EpisodeNoteRecord.timestamp), SortDescriptor(\EpisodeNoteRecord.createdAt)]
        )
        self.showsHeading = showsHeading
        self.onSeek = onSeek
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if showsHeading {
                Label("My Notes", systemImage: "note.text")
                    .font(.headline)
            }
            if notes.isEmpty {
                Text("No notes yet. Tap Add Note in Now Playing to save a thought at that moment.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Button {
                                onSeek(note.timestamp)
                            } label: {
                                Label(EpisodeNoteTime.text(note.timestamp), systemImage: "play.circle")
                                    .font(.subheadline.monospacedDigit())
                            }
                            .accessibilityLabel("Play from \(EpisodeNoteTime.text(note.timestamp))")
                        }
                        Text(note.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    .compositingGroup()
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12))
                    .contextMenu {
                        Button("Delete Note", systemImage: "trash", role: .destructive) {
                            delete(note)
                        }
                        .accessibilityIdentifier("Delete Episode Note")
                    }
                    .accessibilityAction(named: "Delete Note") {
                        delete(note)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("Episode Notes")
        .alert("Couldn’t Delete Note", isPresented: Binding(
            get: { deletionError != nil },
            set: { if !$0 { deletionError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deletionError ?? "")
        }
    }

    private func delete(_ note: EpisodeNoteRecord) {
        do {
            try EpisodeNoteStore.delete(note, in: modelContext)
        } catch {
            deletionError = error.localizedDescription
        }
    }
}
