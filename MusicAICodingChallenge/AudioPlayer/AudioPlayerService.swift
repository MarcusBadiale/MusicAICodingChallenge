import Foundation
import AVFoundation
import MediaPlayer
import Combine
import UIKit

@MainActor
@Observable
final class AudioPlayerService {
    private(set) var queue: PlayQueue = PlayQueue()
    private(set) var isPlaying = false
    private(set) var isBuffering = false
    private(set) var progress: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    var currentItem: MusicItem? { queue.currentItem }
    var hasNext: Bool { queue.hasNext }
    var hasPrevious: Bool { queue.hasPrevious }

    private let queuePlayer = AVQueuePlayer()
    private let repository: MusicRepositoryProtocol
    private var audioSessionActivated = false
    private var cancellables = Set<AnyCancellable>()
    private var timeObserver: Any?

    init(repository: MusicRepositoryProtocol) {
        self.repository = repository
        setupObservers()
        setupNowPlayingCommands()
    }

    // MARK: - Public API
    func play(_ items: [MusicItem], startingAt index: Int = 0) {
        activateAudioSessionIfNeeded()
        queue = PlayQueue(items: items, currentIndex: index)
        rebuildQueuePlayer()
        queuePlayer.play()
        recordPlay()
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        isPlaying ? queuePlayer.pause() : queuePlayer.play()
    }

    func next() {
        guard queue.hasNext else { return }
        queue.advance()
        queuePlayer.advanceToNextItem()
        enqueueUpcoming()
        recordPlay()
        updateNowPlayingInfo()
    }

    func previous() {
        guard queue.hasPrevious else { return }
        queue.regress()
        rebuildQueuePlayer()
        queuePlayer.play()
        recordPlay()
        updateNowPlayingInfo()
    }

    func seek(to seconds: TimeInterval) {
        queuePlayer.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    // MARK: - Queue Management
    private func rebuildQueuePlayer() {
        queuePlayer.removeAllItems()
        for offset in 0...1 {
            guard let item = queue.items[safe: queue.currentIndex + offset],
                  let url = item.previewUrl else { continue }
            queuePlayer.insert(AVPlayerItem(url: url), after: nil)
        }
        updateDuration()
    }

    private func enqueueUpcoming() {
        if let upcoming = queue.upcomingItem,
           let url = upcoming.previewUrl {
            queuePlayer.insert(AVPlayerItem(url: url), after: queuePlayer.items().last)
        }
        updateDuration()
    }

    private func updateDuration() {
        // iTunes preview is ~30s. Use full track duration when streaming full songs:
        // if let millis = queue.currentItem?.trackTimeMillis {
        //     duration = TimeInterval(millis) / 1000.0
        // }
        duration = 30
        progress = 0
    }

    // MARK: - Record Play (fire-and-forget)
    private func recordPlay() {
        guard let item = queue.currentItem else { return }
        Task { try? await repository.recordPlay(item: item) }
        announceTrackChange(item)
    }

    private func announceTrackChange(_ item: MusicItem) {
        UIAccessibility.post(
            notification: .announcement,
            argument: "Now playing: \(item.trackName), \(item.artistName)"
        )
    }

    // MARK: - Audio Session
    private func activateAudioSessionIfNeeded() {
        guard !audioSessionActivated else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        audioSessionActivated = true
    }
}

// MARK: - Observers
extension AudioPlayerService {
    private func setupObservers() {
        timeObserver = queuePlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            Task { @MainActor in
                self.progress = time.seconds
                self.updateNowPlayingProgress()
            }
        }

        queuePlayer.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isBuffering = (status == .waitingToPlayAtSpecifiedRate)
                self?.isPlaying = (status == .playing)
            }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.queue.hasNext {
                    self.queue.advance()
                    self.enqueueUpcoming()
                    self.recordPlay()
                    self.updateNowPlayingInfo()
                }
            }
        }
    }
}

// MARK: - Now Playing + Remote Commands
extension AudioPlayerService {
    private func setupNowPlayingCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.queuePlayer.play() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.queuePlayer.pause() }
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.next() }
            return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.previous() }
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let item = currentItem else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: item.trackName,
            MPMediaItemPropertyArtist: item.artistName,
            MPMediaItemPropertyAlbumTitle: item.albumName ?? "",
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: progress,
            MPMediaItemPropertyPlaybackDuration: duration,
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        if let url = item.artworkUrl {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: data) {
                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                        boundsSize: image.size
                    ) { _ in image }
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                }
            }
        }
    }

    private func updateNowPlayingProgress() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progress
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

// MARK: - Safe Array Access
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
