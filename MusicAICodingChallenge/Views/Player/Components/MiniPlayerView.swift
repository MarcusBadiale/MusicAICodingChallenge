import SwiftUI

struct MiniPlayerView: View {
    let playerService: AudioPlayerService
    let onTap: () -> Void

    var body: some View {
        if let item = playerService.currentItem {
            Button(action: onTap) {
                HStack(spacing: DS.Spacing.md) {
                    CachedAsyncImage(url: item.artworkUrl) {
                        RoundedRectangle(cornerRadius: DS.Radius.sm)
                            .fill(Color(.systemGray6))
                    }
                    .frame(width: DS.Size.miniArtwork, height: DS.Size.miniArtwork)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))

                    VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                        Text(item.trackName)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(item.artistName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        playerService.togglePlayPause()
                    } label: {
                        Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
                            .contentTransition(.symbolEffect(.replace))
                            .font(.system(size: DS.IconSize.md))
                            .foregroundStyle(.primary)
                            .frame(width: DS.Size.tapTarget, height: DS.Size.tapTarget)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        playerService.next()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: DS.IconSize.sm))
                            .foregroundStyle(playerService.hasNext ? .primary : .secondary)
                            .frame(width: DS.Size.tapTarget, height: DS.Size.tapTarget)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!playerService.hasNext)
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.vertical, DS.Spacing.sm)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .padding(.horizontal, DS.Spacing.sm)
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
