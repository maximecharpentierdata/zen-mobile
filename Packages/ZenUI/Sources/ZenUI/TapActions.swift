import SwiftUI

extension View {
    /// Makes the view a button. With `doubleTap`, two taps run it instead, at the cost of a short wait before a
    /// single tap counts, so it is only used where a double tap means something (spec §3.2, §3.4).
    @ViewBuilder
    func onTap(_ tap: @escaping @MainActor () -> Void, doubleTap: (@MainActor () -> Void)?) -> some View {
        if let doubleTap {
            contentShape(.rect)
                .gesture(
                    TapGesture(count: 2).onEnded { doubleTap() }
                        .exclusively(before: TapGesture().onEnded { tap() })
                )
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { tap() }
        } else {
            Button(action: tap) { self }
                .buttonStyle(.plain)
        }
    }
}
