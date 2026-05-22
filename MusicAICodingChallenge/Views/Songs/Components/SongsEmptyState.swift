import SwiftUI

struct SongsEmptyState: View {
    let mode: SongsViewModel.Mode

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DS.Spacing.xl)
    }

    private var message: String {
        switch mode {
        case .recentlyPlayed:
            "No recently played songs"
        case .searching(let query):
            "No results for \"\(query)\""
        }
    }
}

#Preview("Recently Played") {
    SongsEmptyState(mode: .recentlyPlayed)
        .preferredColorScheme(.dark)
}

#Preview("Search") {
    SongsEmptyState(mode: .searching(query: "asdfgh"))
        .preferredColorScheme(.dark)
}
