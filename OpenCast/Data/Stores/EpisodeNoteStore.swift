import Foundation
import SwiftData

enum EpisodeNoteStore {
    enum ValidationError: LocalizedError {
        case emptyNote
        case invalidPosition

        var errorDescription: String? {
            switch self {
            case .emptyNote: "Enter a note before saving."
            case .invalidPosition: "The episode or playback position is unavailable."
            }
        }
    }

    static func delete(_ note: EpisodeNoteRecord, in context: ModelContext) throws {
        context.delete(note)
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    @discardableResult
    static func save(_ text: String, for draft: EpisodeNoteDraft, in context: ModelContext) throws -> EpisodeNoteRecord {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ValidationError.emptyNote }
        guard !draft.episodeID.isEmpty, draft.timestamp.isFinite, draft.timestamp >= 0 else {
            throw ValidationError.invalidPosition
        }
        let note = EpisodeNoteRecord(episodeID: draft.episodeID, timestamp: draft.timestamp, text: trimmed)
        context.insert(note)
        do {
            try context.save()
        } catch {
            context.delete(note)
            throw error
        }
        return note
    }
}
