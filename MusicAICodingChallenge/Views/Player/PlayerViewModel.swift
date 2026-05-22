import Foundation

@MainActor
@Observable
final class PlayerViewModel {
    private let playerService: AudioPlayerService

    init(playerService: AudioPlayerService) {
        self.playerService = playerService
    }

    var currentItem: MusicItem? { playerService.currentItem }
    var isPlaying: Bool { playerService.isPlaying }
    var isBuffering: Bool { playerService.isBuffering }
    var progress: TimeInterval {
        get { playerService.progress }
        set { playerService.seek(to: newValue) }
    }
    var duration: TimeInterval { playerService.duration }
    var hasNext: Bool { playerService.hasNext }
    var hasPrevious: Bool { playerService.hasPrevious }

    var repeatEnabled: Bool = false

    var formattedProgress: String { formatTime(progress) }
    var formattedRemaining: String { "-\(formatTime(max(0, duration - progress)))" }

    var accessibleProgress: String { formatTimeAccessible(progress) }
    var accessibleDuration: String { formatTimeAccessible(duration) }

    func togglePlayPause() {
        playerService.togglePlayPause()
    }

    func next() {
        playerService.next()
    }

    func previous() {
        playerService.previous()
    }

    func seek(to value: TimeInterval) {
        playerService.seek(to: value)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func formatTimeAccessible(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 && secs > 0 {
            return "\(mins) minute\(mins == 1 ? "" : "s") \(secs) second\(secs == 1 ? "" : "s")"
        } else if mins > 0 {
            return "\(mins) minute\(mins == 1 ? "" : "s")"
        } else {
            return "\(secs) second\(secs == 1 ? "" : "s")"
        }
    }
}
