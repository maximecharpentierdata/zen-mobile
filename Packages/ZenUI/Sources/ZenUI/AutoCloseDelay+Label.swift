import SwiftUI
import ZenModel

extension AutoCloseDelay {
    /// The setting's name in the options menu.
    var label: LocalizedStringKey {
        switch self {
        case .twelveHours: "12 hours"
        case .oneDay: "24 hours"
        case .sevenDays: "7 days"
        case .never: "Never"
        }
    }
}
