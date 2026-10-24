import Foundation

/// How long a regular tab can stay unopened before it's closed automatically (spec §3.2).
public enum AutoCloseDelay: String, CaseIterable, Codable, Sendable {
    /// Close after 12 hours.
    case twelveHours
    /// Close after 24 hours. The default.
    case oneDay
    /// Close after 7 days.
    case sevenDays
    /// Never close automatically.
    case never

    /// The delay in seconds, or `nil` for ``never``.
    public var interval: TimeInterval? {
        switch self {
        case .twelveHours: 12 * 3600
        case .oneDay: 24 * 3600
        case .sevenDays: 7 * 24 * 3600
        case .never: nil
        }
    }
}
