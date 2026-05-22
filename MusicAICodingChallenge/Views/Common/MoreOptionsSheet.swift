import SwiftUI

struct MoreOptionsSheet: View {
    let item: MusicItem
    var onViewAlbum: (() -> Void)?

    var body: some View {
        VStack(spacing: DS.Spacing.xxl) {
            VStack(spacing: DS.Spacing.xs) {
                Text(item.trackName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(item.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.top, DS.Spacing.xl)

            if item.collectionId != nil {
                Button {
                    onViewAlbum?()
                } label: {
                    HStack(spacing: DS.Spacing.md) {
                        Image(systemName: "music.note.list")
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text("View album")
                            .font(.body)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .frame(minHeight: DS.Size.tapTarget)
                .contentShape(Rectangle())
            }

            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xl)
        .presentationDetents([.height(DS.Sheet.optionsHeight)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemGray6))
    }
}

#if DEBUG
#Preview {
    MoreOptionsSheet(item: .mock(), onViewAlbum: {})
}
#endif
