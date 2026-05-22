import SwiftUI

struct PlayerView: View {
    @Bindable var viewModel: PlayerViewModel
    var onAlbumTapped: ((Int) -> Void)?

    @State private var showSheet = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            artwork
            Spacer()
            trackInfo
            progressSection
            transportControls
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xl)
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let albumName = viewModel.currentItem?.albumName,
                   let collectionId = viewModel.currentItem?.collectionId {
                    Button {
                        onAlbumTapped?(collectionId)
                    } label: {
                        Text(albumName)
                            .font(.footnote.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSheet = true
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            if let item = viewModel.currentItem {
                MoreOptionsSheet(item: item) {
                    showSheet = false
                    if let collectionId = item.collectionId {
                        onAlbumTapped?(collectionId)
                    }
                }
            }
        }
    }

    // MARK: - Artwork

    private var artwork: some View {
        AsyncImage(url: viewModel.currentItem?.artworkUrl) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .fill(Color(.systemGray6))
        }
        .frame(width: DS.Size.playerArtwork, height: DS.Size.playerArtwork)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
    }

    // MARK: - Track Info

    private var trackInfo: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(viewModel.currentItem?.trackName ?? "")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(viewModel.currentItem?.artistName ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                viewModel.repeatEnabled.toggle()
            } label: {
                Image(systemName: "repeat")
                    .font(.system(size: DS.IconSize.sm))
                    .foregroundStyle(viewModel.repeatEnabled ? .primary : .secondary)
            }
            .buttonStyle(.plain)
            .frame(width: DS.Size.tapTarget, height: DS.Size.tapTarget)
            .contentShape(Rectangle())
            .accessibilityLabel(viewModel.repeatEnabled ? "Repeat on" : "Repeat off")
        }
        .padding(.bottom, DS.Spacing.lg)
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: DS.Spacing.xs) {
            Slider(
                value: $viewModel.progress,
                in: 0...max(viewModel.duration, 1)
            ) { editing in
                if !editing {
                    viewModel.seek(to: viewModel.progress)
                }
            }
            .tint(.primary)

            HStack {
                Text(viewModel.formattedProgress)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()

                Spacer()

                Text(viewModel.formattedRemaining)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(.bottom, DS.Spacing.xxl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress: \(viewModel.formattedProgress) of \(viewModel.formattedRemaining)")
    }

    // MARK: - Transport Controls

    private var transportControls: some View {
        HStack(spacing: DS.Spacing.huge) {
            Button {
                viewModel.previous()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: DS.IconSize.md))
                    .foregroundStyle(viewModel.hasPrevious ? .primary : .secondary)
            }
            .disabled(!viewModel.hasPrevious)
            .buttonStyle(.plain)
            .frame(width: DS.Size.tapTarget, height: DS.Size.tapTarget)
            .contentShape(Rectangle())
            .accessibilityLabel("Previous track")

            Button {
                viewModel.togglePlayPause()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: DS.IconSize.lg))
                    .foregroundStyle(.primary)
                    .frame(width: DS.Size.thumbnail, height: DS.Size.thumbnail)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")

            Button {
                viewModel.next()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: DS.IconSize.md))
                    .foregroundStyle(viewModel.hasNext ? .primary : .secondary)
            }
            .disabled(!viewModel.hasNext)
            .buttonStyle(.plain)
            .frame(width: DS.Size.tapTarget, height: DS.Size.tapTarget)
            .contentShape(Rectangle())
            .accessibilityLabel("Next track")
        }
    }
}

#Preview {
    NavigationStack {
        PlayerView(viewModel: {
            let vm = PlayerViewModel()
            vm.load(
                item: .mock(trackName: "Yellow", artistName: "Coldplay", albumName: "Parachutes"),
                queue: [
                    .mock(id: 1, trackName: "Yellow", artistName: "Coldplay", albumName: "Parachutes"),
                    .mock(id: 2, trackName: "Shiver", artistName: "Coldplay", albumName: "Parachutes"),
                ]
            )
            return vm
        }())
    }
    .preferredColorScheme(.dark)
}
