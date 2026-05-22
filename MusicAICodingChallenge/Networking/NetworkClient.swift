import Foundation

nonisolated final class NetworkClient: NetworkClientProtocol {
    private let transport: HTTPTransport
    private let decoder: JSONDecoder

    init(transport: HTTPTransport = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.transport = transport
        self.decoder = decoder
    }

    func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.makeRequest()
        let (data, response) = try await sendRequest(request)
        try validate(response)
        return try decode(data)
    }

    // MARK: - Pipeline steps

    private func sendRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            return try await transport.send(request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where Self.offlineCodes.contains(error.code) {
            throw MusicError.offline
        } catch let error as MusicError {
            throw error
        } catch {
            throw MusicError.serverError
        }
    }

    private func validate(_ response: HTTPURLResponse) throws {
        guard (200...299).contains(response.statusCode) else {
            throw MusicError.serverError
        }
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do { return try decoder.decode(T.self, from: data) }
        catch { throw MusicError.decodingFailed }
    }

    private static let offlineCodes: Set<URLError.Code> = [
        .notConnectedToInternet,
        .networkConnectionLost,
        .dataNotAllowed,
    ]
}
