import Foundation

#if canImport(CoreGraphics)
    import CoreGraphics
#endif

/// Geometry for the page shrinking into its tab row and growing back (spec §3.4, §3.5; design 3A, 4A).
///
/// The page keeps its layout: it is scaled uniformly around its centre to the row's width, moved onto the
/// row, and masked to the row's height, so at `progress` 1 the visible part is exactly the row.
public struct PageTransform: Equatable, Sendable {
    /// The uniform scale applied to the page.
    public let scale: Double
    /// How far the page's centre moves horizontally.
    public let offsetX: Double
    /// How far the page's centre moves vertically.
    public let offsetY: Double
    /// The visible height, in the page's own (unscaled) points, centred.
    public let maskHeight: Double
    /// The mask's corner radius, in the page's own points.
    public let cornerRadius: Double
    /// The page's opacity, so the row shows through at the end.
    public let opacity: Double

    /// The transform at `progress` (0 = full screen, 1 = on the row) from `page` to `row`, both in the same
    /// coordinate space. `rowCornerRadius` is the row's radius on screen.
    public init(progress: Double, page: CGRect, row: CGRect, rowCornerRadius: Double) {
        let progress = min(max(progress, 0), 1)
        let endScale = page.width > 0 ? row.width / page.width : 1
        scale = Self.lerp(1, endScale, progress)
        offsetX = Self.lerp(0, row.midX - page.midX, progress)
        offsetY = Self.lerp(0, row.midY - page.midY, progress)
        maskHeight = Self.lerp(page.height, endScale > 0 ? row.height / endScale : page.height, progress)
        cornerRadius = Self.lerp(0, endScale > 0 ? rowCornerRadius / endScale : 0, progress)
        opacity = 1 - Self.smoothStep(from: 0.6, to: 1, progress)
    }

    private static func lerp(_ from: Double, _ to: Double, _ amount: Double) -> Double {
        from + (to - from) * amount
    }

    private static func smoothStep(from edge0: Double, to edge1: Double, _ value: Double) -> Double {
        let amount = min(max((value - edge0) / (edge1 - edge0), 0), 1)
        return amount * amount * (3 - 2 * amount)
    }
}
