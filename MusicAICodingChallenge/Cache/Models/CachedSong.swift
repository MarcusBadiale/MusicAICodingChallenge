import Foundation
import SwiftData

@Model
final class CachedSong {
    // MARK: - Song Variables
    @Attribute(.unique) var trackId: Int
    var trackName: String
    var artistName: String
    var albumName: String?
    var artworkUrl: URL?
    var previewUrl: URL?
    var collectionId: Int?
    var trackTimeMillis: Int?
    var genre: String?
    var releaseDate: Date?
    var trackNumber: Int?
    var discNumber: Int?

    // MARK: - Playback Tracking
    var playedAt: Date?
    var playCount: Int = 0

    // MARK: Inits
    init(
        trackId: Int,
        trackName: String,
        artistName: String,
        albumName: String? = nil,
        artworkUrl: URL? = nil,
        previewUrl: URL? = nil,
        collectionId: Int? = nil,
        trackTimeMillis: Int? = nil,
        genre: String? = nil,
        releaseDate: Date? = nil,
        trackNumber: Int? = nil,
        discNumber: Int? = nil,
        playedAt: Date? = nil,
        playCount: Int = 0
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.albumName = albumName
        self.artworkUrl = artworkUrl
        self.previewUrl = previewUrl
        self.collectionId = collectionId
        self.trackTimeMillis = trackTimeMillis
        self.genre = genre
        self.releaseDate = releaseDate
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.playedAt = playedAt
        self.playCount = playCount
    }

    convenience init(from item: MusicItem, playedAt: Date? = nil, playCount: Int = 0) {
        self.init(
            trackId: item.id,
            trackName: item.trackName,
            artistName: item.artistName,
            albumName: item.albumName,
            artworkUrl: item.artworkUrl,
            previewUrl: item.previewUrl,
            collectionId: item.collectionId,
            trackTimeMillis: item.trackTimeMillis,
            genre: item.genre,
            releaseDate: item.releaseDate,
            trackNumber: item.trackNumber,
            discNumber: item.discNumber,
            playedAt: playedAt,
            playCount: playCount
        )
    }

    // MARK: - Mapping
    func toModel() -> MusicItem {
        MusicItem(
            id: trackId,
            trackName: trackName,
            artistName: artistName,
            albumName: albumName,
            artworkUrl: artworkUrl,
            previewUrl: previewUrl,
            trackTimeMillis: trackTimeMillis,
            genre: genre,
            releaseDate: releaseDate,
            collectionId: collectionId,
            trackNumber: trackNumber,
            discNumber: discNumber
        )
    }
}
