import SwiftData
import SwiftUI

struct AddEpisodeNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var text = ""
    @State private var errorMessage: String?
    @FocusState private var isEditing: Bool

    let draft: EpisodeNoteDraft

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(draft.episodeTitle)
                    .font(.headline)
                    .lineLimit(3)
                Label(EpisodeNoteTime.text(draft.timestamp), systemImage: "clock")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                TextEditor(text: $text)
                    .focused($isEditing)
                    .accessibilityLabel("Note")
                    .accessibilityIdentifier("Episode Note Text")
                    .padding(8)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        do {
                            try EpisodeNoteStore.save(text, for: draft, in: modelContext)
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("Save Episode Note")
                }
            }
            .alert("Couldn’t Save Note", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .onAppear { isEditing = true }
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}
