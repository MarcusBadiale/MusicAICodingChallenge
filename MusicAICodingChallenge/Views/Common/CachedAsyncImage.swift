import SwiftUI

struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage?

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            placeholder()
                .task(id: url) {
                    guard let url else { return }
                    image = await ImageCache.shared.load(url)
                }
        }
    }
}
