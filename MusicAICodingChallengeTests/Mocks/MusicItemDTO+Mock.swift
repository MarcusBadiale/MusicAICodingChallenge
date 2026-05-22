import Foundation
@testable import MusicAICodingChallenge

extension MusicItemDTO {
    static func mock(
        id: Int = 1,
        trackName: String = "Mock Track",
        artistName: String = "Mock Artist",
        albumName: String? = "Mock Album",
        artworkUrl: URL? = nil,
        previewUrl: URL? = URL(string: "https://example.com/preview.m4a"),
        trackTimeMillis: Int? = 30_000,
        genre: String? = "Pop",
        releaseDate: Date? = nil,
        collectionId: Int? = 100,
        trackNumber: Int? = nil,
        discNumber: Int? = nil
    ) -> MusicItemDTO {
        MusicItemDTO(
            id: id,
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
