import Foundation
import SwiftData
import Testing
@testable import OpenCast

@MainActor
@Suite("Episode notes")
struct EpisodeNoteStoreTests {
    @Test("Notes retain their episode and captured timestamp across store reopen")
    func persistence() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "notes.store")
        let schema = Schema([EpisodeNoteRecord.self])
        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        do {
            let container = try ModelContainer(for: schema, configurations: configuration)
            let context = ModelContext(container)
            try EpisodeNoteStore.save("  Remember this idea\n", for: draft("episode-a", at: 123.5), in: context)
            try EpisodeNoteStore.save("Other episode", for: draft("episode-b", at: 20), in: context)
            try EpisodeNoteStore.save("Earlier thought", for: draft("episode-a", at: 10), in: context)
        }
        let reopened = try ModelContainer(for: schema, configurations: configuration)
        let context = ModelContext(reopened)
        let episodeID = "episode-a"
        let records = try context.fetch(FetchDescriptor<EpisodeNoteRecord>(
            predicate: #Predicate { $0.episodeID == episodeID },
            sortBy: [SortDescriptor(\EpisodeNoteRecord.timestamp)]
        ))
        #expect(records.map(\.text) == ["Earlier thought", "Remember this idea"])
        #expect(records.map(\.timestamp) == [10, 123.5])
        #expect(records.allSatisfy { $0.episodeID == episodeID })
    }

    @Test("Empty notes and invalid timestamps never insert records")
    func validation() throws {
        let container = try OpenCastModelContainerFactory.make(inMemory: true)
        let context = ModelContext(container)
        #expect(throws: EpisodeNoteStore.ValidationError.self) {
            try EpisodeNoteStore.save(" \n ", for: draft("episode", at: 0), in: context)
        }
        for timestamp in [-1.0, .nan, .infinity] {
            #expect(throws: EpisodeNoteStore.ValidationError.self) {
                try EpisodeNoteStore.save("A thought", for: draft("episode", at: timestamp), in: context)
            }
        }
        #expect(try context.fetchCount(FetchDescriptor<EpisodeNoteRecord>()) == 0)
    }

    @Test("Deleting one note persists and preserves other notes on the episode")
    func deletion() throws {
        let container = try OpenCastModelContainerFactory.make(inMemory: true)
        let context = ModelContext(container)
        let first = try EpisodeNoteStore.save("Delete me", for: draft("episode", at: 10), in: context)
        let kept = try EpisodeNoteStore.save("Keep me", for: draft("episode", at: 20), in: context)
        try EpisodeNoteStore.delete(first, in: context)
        let freshContext = ModelContext(container)
        let notes = try freshContext.fetch(FetchDescriptor<EpisodeNoteRecord>())
        #expect(notes.map(\.noteID) == [kept.noteID])
        #expect(notes.map(\.text) == ["Keep me"])
    }

    private func draft(_ episodeID: String, at timestamp: TimeInterval) -> EpisodeNoteDraft {
        EpisodeNoteDraft(episodeID: episodeID, episodeTitle: "Episode", timestamp: timestamp)
    }
}
