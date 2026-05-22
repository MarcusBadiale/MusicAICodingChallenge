import Foundation
import SwiftData

@ModelActor
actor MusicModelActor {

    // MARK: - Reads

    func fetchRecentlyPlayed(limit: Int) throws -> [MusicItem] {
        var descriptor = FetchDescriptor<CachedSong>(
            predicate: #Predicate { $0.playedAt != nil },
            sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor).map { $0.toModel() }
    }

    func fetchAlbum(collectionId: Int) throws -> [MusicItem] {
        let descriptor = FetchDescriptor<CachedSong>(
            predicate: #Predicate { $0.collectionId == collectionId },
            sortBy: [
                SortDescriptor(\.discNumber),
                SortDescriptor(\.trackNumber),
            ]
        )
        return try modelContext.fetch(descriptor).map { $0.toModel() }
    }

    // MARK: - Writes

    func recordPlay(item: MusicItem) throws {
        let trackId = item.id
        let existing = try modelContext.fetch(
            FetchDescriptor<CachedSong>(predicate: #Predicate { $0.trackId == trackId })
        ).first

        if let song = existing {
            song.playedAt = .now
            song.playCount += 1
        } else {
            modelContext.insert(CachedSong(from: item, playedAt: .now, playCount: 1))
        }
        try modelContext.save()
    }

    func saveAlbumTracks(_ items: [MusicItem]) throws {
        for item in items {
            let trackId = item.id
            let existing = try modelContext.fetch(
                FetchDescriptor<CachedSong>(predicate: #Predicate { $0.trackId == trackId })
            ).first

            if existing == nil {
                modelContext.insert(CachedSong(from: item))
            }
        }
        try modelContext.save()
    }
}
