import SwiftUI

struct EmptyStateView: View {
    let mode: Mode
    var onRetry: (() -> Void)?

    var body: some View {
        if case .noResults(let query) = mode {
            ContentUnavailableView.search(text: query)
        } else if mode.hasRetry {
            ContentUnavailableView {
                Label(mode.title, systemImage: mode.systemImage)
            } description: {
                Text(mode.description)
            } actions: {
                if let onRetry {
                    Button("Try Again", action: onRetry)
                }
            }
        } else {
            ContentUnavailableView(
                mode.title,
                systemImage: mode.systemImage,
                description: Text(mode.description)
            )
        }
    }
}

extension EmptyStateView {
    enum Mode {
        case recentlyPlayed
        case noResults(query: String)
        case offline
        case error
        case albumError

        var title: String {
            switch self {
            case .recentlyPlayed: "No recently played songs"
            case .noResults: "No results found"
            case .offline: "No internet connection"
            case .error: "Couldn't load results"
            case .albumError: "Something went wrong"
            }
        }

        var description: String {
            switch self {
            case .recentlyPlayed: "Search for songs to start listening"
            case .noResults(let query): "No results for \"\(query)\""
            case .offline: "Check your network and try again"
            case .error: "Something went wrong. Please try again."
            case .albumError: "Couldn't load album. Please try again."
            }
        }

        var systemImage: String {
            switch self {
            case .recentlyPlayed: "music.note"
            case .noResults: "magnifyingglass"
            case .offline: "wifi.slash"
            case .error, .albumError: "exclamationmark.triangle"
            }
        }

        var hasRetry: Bool {
            switch self {
            case .offline, .error, .albumError: true
            case .recentlyPlayed, .noResults: false
            }
        }
    }
}
