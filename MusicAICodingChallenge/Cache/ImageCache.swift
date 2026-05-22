import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private let urlCache: URLCache
    private let memoryCache = NSCache<NSURL, UIImage>()

    private init() {
        urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,  // 50 MB memory
            diskCapacity: 200 * 1024 * 1024,    // 200 MB disk
            directory: FileManager.default
                .urls(for: .cachesDirectory, in: .userDomainMask)[0]
                .appending(path: "artwork_cache")
        )
    }

    func load(_ url: URL) async -> UIImage? {
        let request = URLRequest(url: url)

        // 1. Memory cache (instant)
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached
        }

        // 2. Disk cache (no network)
        if let cachedResponse = urlCache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            memoryCache.setObject(image, forKey: url as NSURL)
            return image
        }

        // 3. Network + save to both caches
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let image = UIImage(data: data) else { return nil }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            urlCache.storeCachedResponse(cachedResponse, for: request)
            memoryCache.setObject(image, forKey: url as NSURL)

            return image
        } catch {
            return nil
        }
    }
}
