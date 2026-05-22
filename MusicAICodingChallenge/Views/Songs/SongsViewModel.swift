import Foundation

@MainActor
@Observable
final class SongsViewModel {
    enum Mode: Equatable {
        case recentlyPlayed
        case searching(query: String)
    }

    private(set) var items: [MusicItem] = []
    private(set) var mode: Mode = .recentlyPlayed
    private(set) var hasMore: Bool = false
    private(set) var state: ViewState = .idle

    var searchText: String = "" {
        didSet { onSearchTextChanged() }
    }

    private let repository: MusicRepositoryProtocol
    private var searchTask: Task<Void, Never>?
    private let pageSize = 20

    init(repository: MusicRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Lifecycle
    func onAppear() async {
        guard case .recentlyPlayed = mode, items.isEmpty else { return }
        await loadRecentlyPlayed()
    }

    // MARK: - Triggers
    private func onSearchTextChanged() {
        searchTask?.cancel()

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            mode = .recentlyPlayed
            searchTask = Task { [weak self] in
                await self?.loadRecentlyPlayed()
            }
            return
        }

        mode = .searching(query: query)
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await self?.performSearch(query: query, reset: true)
        }
    }

    func loadMore() {
        guard case .searching(let query) = mode, hasMore, state != .loading else { return }
        searchTask = Task { [weak self] in
            await self?.performSearch(query: query, reset: false)
        }
    }

    func refresh() async {
        switch mode {
        case .recentlyPlayed:
            await loadRecentlyPlayed()
        case .searching(let query):
            await performSearch(query: query, reset: true)
        }
    }

    // MARK: - Recently played
    private func loadRecentlyPlayed() async {
        state = .loading
        do {
            let recent = try await repository.getRecentlyPlayed(limit: 50)
            guard !Task.isCancelled, mode == .recentlyPlayed else { return }
            items = recent
            hasMore = false
            state = recent.isEmpty ? .idle : .loaded
        } catch let error as MusicError {
            state = .error(error)
        } catch {
            state = .error(.serverError)
        }
    }

    // MARK: - Search
    private func performSearch(query: String, reset: Bool) async {
        state = .loading
        let offset = reset ? 0 : items.count

        do {
            let result = try await repository.search(
                query: query, offset: offset, limit: pageSize
            )
            guard !Task.isCancelled, mode == .searching(query: query) else { return }

            if reset {
                items = result.items
            } else {
                items.append(contentsOf: result.items)
            }

            hasMore = result.items.count == pageSize
            state = items.isEmpty ? .error(.empty) : .loaded
        } catch is CancellationError {
            // user changed text — next task handles state
        } catch let error as MusicError {
            state = .error(error)
        } catch {
            state = .error(.serverError)
        }
    }
}
