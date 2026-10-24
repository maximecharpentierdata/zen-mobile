import SwiftUI

/// Links the space screen's search field to the new tab's address field, so that the one field moves from the
/// bottom bar to the middle of the screen and back (spec §3.6).
///
/// Without a namespace, as with Reduce Motion, the two fields only crossfade (spec §5).
struct AddressFieldMatch: ViewModifier {
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let namespace {
            content.matchedGeometryEffect(id: Self.id, in: namespace)
        } else {
            content
        }
    }

    private static let id = "addressField"
}
