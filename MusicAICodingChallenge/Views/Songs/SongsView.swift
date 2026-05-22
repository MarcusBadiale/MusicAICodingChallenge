import SwiftUI

struct SongsView: View {
    @Environment(Navigator.self) private var navigator
    @State private var viewModel: SongsViewModel

    @State private var sheetItem: MusicItem?
    @State private var isSearchCollapsed = false
    @State private var isSearchPresented = false
    @State private var scrollProxy: ScrollViewProxy?

    init(repository: MusicRepositoryProtocol) {
        _viewModel = State(initialValue: SongsViewModel(repository: repository))
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                    SongRow(item: item) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        navigator.navigateToPlayer(item: item, queue: viewModel.items)
                    } onMoreTapped: {
                        sheetItem = item
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .id(index)
                    .onAppear {
                        if index == viewModel.items.count - 5,
                           viewModel.hasMore,
                           case .searching = viewModel.mode {
                            viewModel.loadMore()
                        }
                    }
                }

                if viewModel.hasMore, !viewModel.items.isEmpty,
                   case .searching = viewModel.mode {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top > 0
            } action: { _, collapsed in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSearchCollapsed = collapsed
                }
            }
            .onAppear { scrollProxy = proxy }
        }
        .background(Color.black)
        .overlay {
            if viewModel.state == .idle, viewModel.items.isEmpty {
                EmptyStateView(mode: .recentlyPlayed)
            }

            if case .error(.empty) = viewModel.state,
               case .searching(let query) = viewModel.mode {
                EmptyStateView(mode: .noResults(query: query))
            }

            if case .error(let error) = viewModel.state, error == .offline {
                EmptyStateView(mode: .offline) { Task { await viewModel.refresh() } }
            }

            if case .error(let error) = viewModel.state,
               error != .empty, error != .offline {
                EmptyStateView(mode: .error) { Task { await viewModel.refresh() } }
            }

            if viewModel.state == .loading, viewModel.items.isEmpty,
               case .searching = viewModel.mode {
                VStack {
                    SkeletonList()
                    Spacer()
                }
            }
        }
        .searchable(text: $viewModel.searchText, isPresented: $isSearchPresented, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
        .navigationTitle("Songs")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if isSearchCollapsed {
                    Button {
                        withAnimation {
                            scrollProxy?.scrollTo(0, anchor: .top)
                        }
                        isSearchPresented = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                    }
                    .transition(.opacity)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task(id: navigator.path.count) {
            await viewModel.onAppear()
        }
        .sheet(item: $sheetItem) { item in
            MoreOptionsSheet(item: item) {
                sheetItem = nil
                if let collectionId = item.collectionId {
                    navigator.navigateToAlbum(collectionId: collectionId)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SongsView(repository: PreviewRepository())
    }
    .environment(Navigator(
        repository: PreviewRepository(),
        playerService: AudioPlayerService(repository: PreviewRepository())
    ))
    .preferredColorScheme(.dark)
}
#endif
