import Foundation

enum JSONStub: String {
    case searchAdele = "search_adele"
    case searchEmpty = "search_empty"
    case searchMinimalFields = "search_minimal_fields"
    case searchArtwork100 = "search_artwork_100"
    case albumLookup = "album_lookup"
    case malformed = "malformed"

    var data: Data {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: rawValue, withExtension: "json") else {
            fatalError("Missing stub: \(rawValue).json — add it to Mocks/Responses/ and ensure it belongs to the test target")
        }
        return try! Data(contentsOf: url)
    }

    private final class BundleToken {}
}
