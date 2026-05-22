import Foundation

nonisolated struct SearchResultDTO: Sendable, Equatable {
    let items: [MusicItemDTO]
    let totalCount: Int
}
