import SwiftUI

struct SongsView: View {
    @Bindable var viewModel: SongsViewModel
    var onSongTapped: (MusicItem, [MusicItem]) -> Void
    var onViewAlbum: (Int) -> Void

    @State private var sheetItem: MusicItem?
    @State private var isSearchCollapsed = false

    var body: some View {
        List {
            ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                SongRow(item: item) {
                    sheetItem = item
                }
                .onTapGesture {
                    onSongTapped(item, viewModel.items)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onAppear {
                    if index == viewModel.items.count - 5,
                       viewModel.hasMore,
                       case .searching = viewModel.mode {
                        viewModel.loadMore()
                    }
                }
            }

            if viewModel.hasMore, case .searching = viewModel.mode {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .overlay {
            if viewModel.state == .idle, viewModel.items.isEmpty {
                SongsEmptyState(mode: viewModel.mode)
            }

            if case .error(.empty) = viewModel.state {
                SongsEmptyState(mode: viewModel.mode)
            }

            if case .error(let error) = viewModel.state, error != .empty {
                VStack(spacing: DS.Spacing.md) {
                    Text(error == .offline
                         ? "No internet connection.\nCheck your network and try again."
                         : "Couldn't load results.\nPlease try again.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        Task { await viewModel.refresh() }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                }
            }

            if viewModel.state == .loading, viewModel.items.isEmpty {
                ProgressView()
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top > 0
        } action: { _, collapsed in
            withAnimation(.easeInOut(duration: 0.2)) {
                isSearchCollapsed = collapsed
            }
        }
        .navigationTitle("Songs")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if isSearchCollapsed {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                        .transition(.opacity)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.onAppear()
        }
        .sheet(item: $sheetItem) { item in
            MoreOptionsSheet(item: item) {
                sheetItem = nil
                if let collectionId = item.collectionId {
                    onViewAlbum(collectionId)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SongsView(
            viewModel: SongsViewModel(repository: PreviewRepository()),
            onSongTapped: { _, _ in },
            onViewAlbum: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
