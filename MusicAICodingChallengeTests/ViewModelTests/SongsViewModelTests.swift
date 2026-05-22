import Testing
import Foundation
@testable import MusicAICodingChallenge

@MainActor
struct SongsViewModelTests {

    // MARK: - Helpers

    private func makeViewModel(
        repository: MockMusicRepository = MockMusicRepository()
    ) -> (SongsViewModel, MockMusicRepository) {
        let vm = SongsViewModel(repository: repository)
        return (vm, repository)
    }

    // MARK: - Recently Played mode

    @Test func onAppearLoadsRecentlyPlayed() async {
        let repo = MockMusicRepository()
        repo.recentlyPlayedHandler = { _ in
            [.mock(id: 1, trackName: "Recent")]
        }
        let (vm, _) = makeViewModel(repository: repo)

        await vm.onAppear()

        #expect(vm.items.count == 1)
        #expect(vm.items[0].trackName == "Recent")
        #expect(vm.state == .loaded)
        #expect(vm.mode == .recentlyPlayed)
    }

    @Test func onAppearEmptyRecentlyPlayedSetsIdle() async {
        let (vm, _) = makeViewModel()

        await vm.onAppear()

        #expect(vm.items.isEmpty)
        #expect(vm.state == .idle)
    }

    @Test func onAppearDoesNotReloadIfAlreadyLoaded() async {
        let repo = MockMusicRepository()
        repo.recentlyPlayedHandler = { _ in [.mock(id: 1)] }
        let (vm, _) = makeViewModel(repository: repo)

        await vm.onAppear()
        await vm.onAppear()

        #expect(repo.recentlyPlayedCallCount == 1)
    }

    // MARK: - Mode transitions

    @Test func initialModeIsRecentlyPlayed() {
        let (vm, _) = makeViewModel()
        #expect(vm.mode == .recentlyPlayed)
    }

    @Test func hasMoreIsFalseInRecentlyPlayedMode() async {
        let repo = MockMusicRepository()
        repo.recentlyPlayedHandler = { _ in [.mock(id: 1)] }
        let (vm, _) = makeViewModel(repository: repo)

        await vm.onAppear()

        #expect(vm.hasMore == false)
    }

    // MARK: - Error handling

    @Test func recentlyPlayedErrorSetsErrorState() async {
        let repo = MockMusicRepository()
        repo.recentlyPlayedHandler = { _ in throw MusicError.serverError }
        let (vm, _) = makeViewModel(repository: repo)

        await vm.onAppear()

        #expect(vm.state == .error(.serverError))
    }
}
