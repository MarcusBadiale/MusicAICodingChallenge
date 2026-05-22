import Foundation

nonisolated struct MusicItemDTO: Sendable, Equatable, Identifiable, Hashable {
    let id: Int
    let trackName: String
    let artistName: String
    let albumName: String?
    let artworkUrl: URL?
    let previewUrl: URL?
    let trackTimeMillis: Int?
    let genre: String?
    let releaseDate: Date?
    let collectionId: Int?
    let trackNumber: Int?
    let discNumber: Int?
}
