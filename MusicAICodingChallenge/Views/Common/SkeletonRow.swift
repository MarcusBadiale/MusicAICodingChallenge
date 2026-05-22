import SwiftUI

struct SkeletonRow: View {
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .fill(Color(.systemGray5))
                .frame(width: DS.Size.thumbnail, height: DS.Size.thumbnail)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 140, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 90, height: 12)
            }

            Spacer()
        }
        .padding(.vertical, DS.Spacing.xs)
        .shimmer()
    }
}

struct SkeletonList: View {
    var count: Int = 6

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonRow()
            }
        }
        .padding(.horizontal, DS.Spacing.xl)
    }
}

struct SkeletonAlbumHero: View {
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(Color(.systemGray5))
                .frame(width: DS.Size.albumArtwork, height: DS.Size.albumArtwork)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 160, height: 18)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 100, height: 14)
        }
        .shimmer()
    }
}

#Preview {
    VStack {
        SkeletonAlbumHero()
        SkeletonList()
    }
    .preferredColorScheme(.dark)
}
