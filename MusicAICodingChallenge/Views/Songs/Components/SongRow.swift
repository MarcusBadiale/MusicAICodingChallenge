import SwiftUI

struct SongRow: View {
    let item: MusicItem
    var showMoreButton: Bool = true
    var onMoreTapped: (() -> Void)?

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            AsyncImage(url: item.artworkUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(Color(.systemGray6))
            }
            .frame(width: DS.Size.thumbnail, height: DS.Size.thumbnail)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))

            VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                Text(item.trackName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(item.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if showMoreButton {
                Button {
                    onMoreTapped?()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(width: DS.Size.tapTarget, height: DS.Size.tapTarget)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, DS.Spacing.xs)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.trackName), \(item.artistName)")
    }
}

#Preview {
    List {
        SongRow(item: .mock(trackName: "Yellow", artistName: "Coldplay"))
            .listRowBackground(Color.clear)

        SongRow(item: .mock(id: 2, trackName: "Fix You", artistName: "Coldplay"), showMoreButton: false)
            .listRowBackground(Color.clear)
    }
    .listStyle(.plain)
    .preferredColorScheme(.dark)
}
