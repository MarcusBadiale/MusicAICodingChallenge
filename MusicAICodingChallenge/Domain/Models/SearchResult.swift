import Foundation

struct SearchResult: Sendable, Equatable {
    let items: [MusicItem]
    let totalCount: Int
}
