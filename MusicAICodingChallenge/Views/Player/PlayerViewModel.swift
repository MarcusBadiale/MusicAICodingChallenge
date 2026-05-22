import Foundation

@MainActor
@Observable
final class PlayerViewModel {
    private(set) var currentItem: MusicItem?
    private(set) var queue: [MusicItem] = []
    private(set) var currentIndex: Int = 0

    private(set) var isPlaying: Bool = false
    var progress: TimeInterval = 0
    private(set) var duration: TimeInterval = 30

    var repeatEnabled: Bool = false

    var hasNext: Bool { currentIndex + 1 < queue.count }
    var hasPrevious: Bool { currentIndex > 0 }

    var formattedProgress: String { formatTime(progress) }
    var formattedRemaining: String { "-\(formatTime(max(0, duration - progress)))" }

    func load(item: MusicItem, queue: [MusicItem]) {
        self.queue = queue
        self.currentIndex = queue.firstIndex(where: { $0.id == item.id }) ?? 0
        self.currentItem = queue.indices.contains(currentIndex) ? queue[currentIndex] : item
        self.isPlaying = false
        self.progress = 0
    }

    func togglePlayPause() {
        isPlaying.toggle()
    }

    func next() {
        guard hasNext else { return }
        currentIndex += 1
        currentItem = queue[currentIndex]
        progress = 0
    }

    func previous() {
        guard hasPrevious else { return }
        currentIndex -= 1
        currentItem = queue[currentIndex]
        progress = 0
    }

    func seek(to value: TimeInterval) {
        progress = value
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
