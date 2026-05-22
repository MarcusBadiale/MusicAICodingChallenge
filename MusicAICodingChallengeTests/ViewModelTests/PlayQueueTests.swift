import Testing
import Foundation
@testable import MusicAICodingChallenge

struct PlayQueueTests {
    private let items: [MusicItem] = [
        .mock(id: 1, trackName: "Track 1"),
        .mock(id: 2, trackName: "Track 2"),
        .mock(id: 3, trackName: "Track 3"),
    ]

    // MARK: - Init
    @Test func emptyQueueHasNoCurrentItem() {
        let queue = PlayQueue()
        #expect(queue.currentItem == nil)
        #expect(!queue.hasNext)
        #expect(!queue.hasPrevious)
    }

    @Test func initClampsNegativeIndex() {
        let queue = PlayQueue(items: items, currentIndex: -5)
        #expect(queue.currentIndex == 0)
        #expect(queue.currentItem?.id == 1)
    }

    @Test func initClampsIndexBeyondBounds() {
        let queue = PlayQueue(items: items, currentIndex: 100)
        #expect(queue.currentIndex == 2)
        #expect(queue.currentItem?.id == 3)
    }

    @Test func initSetsCorrectIndex() {
        let queue = PlayQueue(items: items, currentIndex: 1)
        #expect(queue.currentIndex == 1)
        #expect(queue.currentItem?.id == 2)
    }

    // MARK: - Navigation
    @Test func advanceMovesForward() {
        var queue = PlayQueue(items: items, currentIndex: 0)
        queue.advance()
        #expect(queue.currentIndex == 1)
        #expect(queue.currentItem?.id == 2)
    }

    @Test func advanceIsNoOpAtEnd() {
        var queue = PlayQueue(items: items, currentIndex: 2)
        queue.advance()
        #expect(queue.currentIndex == 2)
        #expect(queue.currentItem?.id == 3)
    }

    @Test func regressMovesBackward() {
        var queue = PlayQueue(items: items, currentIndex: 2)
        queue.regress()
        #expect(queue.currentIndex == 1)
        #expect(queue.currentItem?.id == 2)
    }

    @Test func regressIsNoOpAtStart() {
        var queue = PlayQueue(items: items, currentIndex: 0)
        queue.regress()
        #expect(queue.currentIndex == 0)
        #expect(queue.currentItem?.id == 1)
    }

    // MARK: - hasNext / hasPrevious
    @Test func hasNextIsTrueWhenNotAtEnd() {
        let queue = PlayQueue(items: items, currentIndex: 0)
        #expect(queue.hasNext)
    }

    @Test func hasNextIsFalseAtEnd() {
        let queue = PlayQueue(items: items, currentIndex: 2)
        #expect(!queue.hasNext)
    }

    @Test func hasPreviousIsTrueWhenNotAtStart() {
        let queue = PlayQueue(items: items, currentIndex: 1)
        #expect(queue.hasPrevious)
    }

    @Test func hasPreviousIsFalseAtStart() {
        let queue = PlayQueue(items: items, currentIndex: 0)
        #expect(!queue.hasPrevious)
    }

    // MARK: - Upcoming
    @Test func upcomingItemReturnsNextTrack() {
        let queue = PlayQueue(items: items, currentIndex: 0)
        #expect(queue.upcomingItem?.id == 2)
    }

    @Test func upcomingItemIsNilAtEnd() {
        let queue = PlayQueue(items: items, currentIndex: 2)
        #expect(queue.upcomingItem == nil)
    }

    // MARK: - Single item queue
    @Test func singleItemQueueHasNoNavigation() {
        let queue = PlayQueue(items: [.mock(id: 1)], currentIndex: 0)
        #expect(queue.currentItem?.id == 1)
        #expect(!queue.hasNext)
        #expect(!queue.hasPrevious)
        #expect(queue.upcomingItem == nil)
    }

    // MARK: - Full traversal
    @Test func fullForwardTraversal() {
        var queue = PlayQueue(items: items, currentIndex: 0)
        #expect(queue.currentItem?.id == 1)
        queue.advance()
        #expect(queue.currentItem?.id == 2)
        queue.advance()
        #expect(queue.currentItem?.id == 3)
        queue.advance()
        #expect(queue.currentItem?.id == 3) // no-op at end
    }
}
