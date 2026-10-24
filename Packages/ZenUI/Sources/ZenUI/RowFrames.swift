import SwiftUI
import ZenModel

/// Where each tab's row is on screen, so a page can grow from its row and shrink back into it (design 3A).
///
/// A plain reference, not observed: rows update it while scrolling without redrawing the whole screen.
@MainActor
final class RowFrames {
    private var frames: [ZenModel.Tab.ID: CGRect] = [:]

    func set(_ frame: CGRect, for id: ZenModel.Tab.ID) {
        frames[id] = frame
    }

    /// The row's last known frame in global coordinates, if it has been on screen.
    func frame(for id: ZenModel.Tab.ID) -> CGRect? {
        frames[id]
    }
}

extension EnvironmentValues {
    /// Where rows report their frames. `nil` outside ``RootView``, for example in previews of a single row.
    @Entry var rowFrames: RowFrames?
}

extension View {
    /// Reports this view's global frame as the row of `tabID`.
    func reportsRowFrame(for tabID: ZenModel.Tab.ID) -> some View {
        modifier(RowFrameReporter(tabID: tabID))
    }
}

private struct RowFrameReporter: ViewModifier {
    let tabID: ZenModel.Tab.ID
    @Environment(\.rowFrames) private var rowFrames

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { frame in
            rowFrames?.set(frame, for: tabID)
        }
    }
}
