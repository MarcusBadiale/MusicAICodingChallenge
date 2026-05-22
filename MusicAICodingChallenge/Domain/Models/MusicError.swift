import Foundation

nonisolated enum MusicError: Error, Equatable {
    case offline
    case serverError
    case decodingFailed
    case empty
}
