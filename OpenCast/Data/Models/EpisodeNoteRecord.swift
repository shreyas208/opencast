import Foundation
import SwiftData

@Model
final class EpisodeNoteRecord {
    var noteID: String = UUID().uuidString
    var episodeID: String = ""
    var timestamp: TimeInterval = 0
    var text: String = ""
    var createdAt: Date = Date()

    init(episodeID: String, timestamp: TimeInterval, text: String) {
        self.episodeID = episodeID
        self.timestamp = timestamp
        self.text = text
    }
}

/// Captured when Add Note is tapped, so playback or an episode change cannot
/// move the note while the listener is typing.
struct EpisodeNoteDraft: Identifiable {
    let id = UUID()
    let episodeID: String
    let episodeTitle: String
    let timestamp: TimeInterval
    var resumesPlaybackOnDismiss = false
}

enum EpisodeNoteTime {
    static func text(_ timestamp: TimeInterval) -> String {
        let seconds = Int(max(0, min(timestamp.isFinite ? timestamp : 0, Double(Int.max / 2))))
        if seconds >= 3600 {
            return String(format: "%d:%02d:%02d", seconds / 3600, seconds / 60 % 60, seconds % 60)
        }
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
