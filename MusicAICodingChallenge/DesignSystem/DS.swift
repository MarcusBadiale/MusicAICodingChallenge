import SwiftUI

enum DS {
    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
    }

    // MARK: - Component Sizes
    enum Size {
        static let tapTarget: CGFloat = 44
        static let thumbnail: CGFloat = 56
        static let albumArtwork: CGFloat = 200
        static let playerArtwork: CGFloat = 280
    }

    // MARK: - Icon Sizes
    enum IconSize {
        static let sm: CGFloat = 18
        static let md: CGFloat = 22
        static let lg: CGFloat = 28
    }

    // MARK: - Sheet
    enum Sheet {
        static let optionsHeight: CGFloat = 180
    }
}
