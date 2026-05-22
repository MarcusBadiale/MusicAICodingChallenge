import Foundation

struct PlayQueue: Sendable, Equatable {
    let items: [MusicItem]
    private(set) var currentIndex: Int

    init(items: [MusicItem] = [], currentIndex: Int = 0) {
        self.items = items
        self.currentIndex = items.isEmpty ? 0 : max(0, min(currentIndex, items.count - 1))
    }

    var currentItem: MusicItem? { items[safe: currentIndex] }
    var upcomingItem: MusicItem? { items[safe: currentIndex + 1] }
    var hasNext: Bool { currentIndex + 1 < items.count }
    var hasPrevious: Bool { currentIndex > 0 }

    mutating func advance() {
        guard hasNext else { return }
        currentIndex += 1
    }

    mutating func regress() {
        guard hasPrevious else { return }
        currentIndex -= 1
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
