import Foundation

enum ITunesEndpoint: Endpoint {
    case search(query: String, offset: Int, limit: Int)
    case lookup(collectionId: Int)

    var baseURL: URL { URL(string: "https://itunes.apple.com")! }
    var method: HTTPMethod { .get }

    var path: String {
        switch self {
        case .search: "/search"
        case .lookup: "/lookup"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .search(let query, let offset, let limit):
            [
                URLQueryItem(name: "term", value: query),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset)),
            ]
        case .lookup(let collectionId):
            [
                URLQueryItem(name: "id", value: String(collectionId)),
                URLQueryItem(name: "entity", value: "song"),
            ]
        }
    }
}
