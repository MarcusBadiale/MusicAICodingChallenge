import SwiftUI

struct AlbumView: View {
    @Environment(Navigator.self) private var navigator
    @State private var viewModel: AlbumViewModel

    init(collectionId: Int, repository: MusicRepositoryProtocol) {
        _viewModel = State(initialValue: AlbumViewModel(
            collectionId: collectionId,
            repository: repository
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                albumHero
                trackList
            }
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.onAppear()
        }
        .overlay {
            if viewModel.state == .loading {
                ProgressView()
            }

            if case .error(let error) = viewModel.state, error == .offline {
                EmptyStateView(mode: .offline) { Task { await viewModel.onAppear() } }
            }

            if case .error(let error) = viewModel.state,
               error != .empty, error != .offline {
                EmptyStateView(mode: .albumError) { Task { await viewModel.onAppear() } }
            }
        }
    }

    // MARK: - Album Hero
    private var albumHero: some View {
        VStack(spacing: DS.Spacing.md) {
            let firstTrack = viewModel.tracks.first

            AsyncImage(url: firstTrack?.artworkUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(Color(.systemGray6))
            }
            .frame(width: DS.Size.albumArtwork, height: DS.Size.albumArtwork)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

            if let albumName = firstTrack?.albumName {
                Text(albumName)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }

            if let artistName = firstTrack?.artistName {
                Text(artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, DS.Spacing.lg)
        .padding(.bottom, DS.Spacing.xxxl)
    }

    // MARK: - Track List
    private var trackList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.tracks) { track in
                SongRow(item: track, showMoreButton: false)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigator.navigateToPlayer(item: track, queue: viewModel.tracks)
                    }
                    .padding(.horizontal, DS.Spacing.xl)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlbumView(collectionId: 1, repository: PreviewRepository())
    }
    .environment(Navigator(
        repository: PreviewRepository(),
        playerService: AudioPlayerService(repository: PreviewRepository())
    ))
    .preferredColorScheme(.dark)
}
