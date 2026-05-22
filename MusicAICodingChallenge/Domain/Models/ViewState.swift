import Foundation

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(MusicError)
}
