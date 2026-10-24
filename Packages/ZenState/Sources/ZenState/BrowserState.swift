import Foundation
import Observation
import ZenModel
import ZenStore

/// The app's live state. Views read it; every change goes through its methods, which call `ZenModel`
/// and then save in the background (architecture §4).
@MainActor
@Observable
public final class BrowserState {
    /// The current data. Change it only through this class's methods.
    public private(set) var data: BrowserData
    /// The last error from a refused change or a failed save, for logging or display.
    public private(set) var lastError: (any Error)?
    /// The tab shown full screen, or `nil` on the space screen. Not saved: the app always opens on the
    /// space screen (spec §3.1).
    public internal(set) var openTabID: Tab.ID?
    /// Whether the address field is being edited (spec §3.4, §3.6).
    public internal(set) var isEditingAddress = false
    /// The engine for typed text that isn't an address. A setting will come later (spec §3.6).
    public let searchEngine: SearchEngine = .google

    @ObservationIgnored private let store: FileStore?
    @ObservationIgnored private let saveDelay: Duration
    @ObservationIgnored private var pendingSave: Task<Void, Never>?
    @ObservationIgnored private let clock: @Sendable () -> Date

    /// Creates a state from existing data. With a `store`, changes are saved after `saveDelay`.
    public init(
        data: BrowserData,
        store: FileStore? = nil,
        saveDelay: Duration = .milliseconds(500),
        clock: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.data = data
        self.store = store
        self.saveDelay = saveDelay
        self.clock = clock
    }

    /// Loads the saved data, or starts fresh. An unreadable file is moved aside first, never overwritten.
    public static func load(from store: FileStore) -> BrowserState {
        do {
            if let data = try store.load() {
                return BrowserState(data: data, store: store)
            }
        } catch {
            _ = try? store.moveAside()
        }
        return BrowserState(data: .firstLaunch(), store: store)
    }

    /// The current time, from the injected clock.
    public var now: Date { clock() }

    /// Applies a model change. A refused change leaves the data as it was and is kept in ``lastError``.
    /// Returns whether the change was applied.
    @discardableResult
    public func perform(_ change: (inout BrowserData) throws -> Void) -> Bool {
        var copy = data
        do {
            try change(&copy)
        } catch {
            lastError = error
            return false
        }
        data = copy
        scheduleSave()
        return true
    }

    /// Saves now, cancelling any pending save. Call it when the app goes to the background.
    public func saveNow() {
        pendingSave?.cancel()
        pendingSave = nil
        guard let store else { return }
        do {
            try store.save(data)
        } catch {
            lastError = error
        }
    }

    private func scheduleSave() {
        guard store != nil else { return }
        pendingSave?.cancel()
        let delay = saveDelay
        pendingSave = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            self?.saveNow()
        }
    }
}
