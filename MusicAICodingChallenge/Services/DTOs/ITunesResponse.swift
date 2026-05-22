import Foundation

struct ITunesResponse: Decodable, Sendable {
    let resultCount: Int
    let results: [ITunesTrack]
}
