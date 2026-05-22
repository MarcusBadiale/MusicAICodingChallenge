import Foundation

nonisolated struct ITunesTrack: Decodable, Sendable {
    let wrapperType: String?
    let kind: String?
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionId: Int?
    let collectionName: String?
    let previewUrl: String?
    let artworkUrl100: String?
    let trackTimeMillis: Int?
    let releaseDate: Date?
    let primaryGenreName: String?
    let trackNumber: Int?
    let discNumber: Int?

    func toDTO() -> MusicItemDTO? {
        guard let trackId, let trackName, let artistName else { return nil }

        let artworkUrl: URL? = artworkUrl100
            .map { $0.replacingOccurrences(of: "100x100bb", with: "600x600bb") }
            .flatMap { URL(string: $0) }

        return MusicItemDTO(
            id: trackId,
            trackName: trackName,
            artistName: artistName,
            albumName: collectionName,
            artworkUrl: artworkUrl,
            previewUrl: previewUrl.flatMap { URL(string: $0) },
            trackTimeMillis: trackTimeMillis,
            genre: primaryGenreName,
            releaseDate: releaseDate,
            collectionId: collectionId,
            trackNumber: trackNumber,
            discNumber: discNumber
        )
    }
}
