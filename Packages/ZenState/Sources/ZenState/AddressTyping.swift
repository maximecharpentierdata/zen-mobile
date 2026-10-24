import ZenModel

/// What the address field shows while the user types: their text followed by an inline completion, which is
/// selected so the next key replaces it and Delete removes it (spec §3.4, §3.6).
public struct AddressTyping: Equatable, Sendable {
    /// What the user typed, without the completion.
    public private(set) var typed: String
    /// The text in the field: ``typed`` followed by the completion, if there is one.
    public private(set) var shown: String

    /// Starts from the field's first text, with no completion.
    public init(text: String) {
        typed = text
        shown = text
    }

    /// The part of ``shown`` that is the completion, or `nil` when there is none.
    public var completionRange: Range<String.Index>? {
        guard shown.count > typed.count else { return nil }
        return shown.index(shown.startIndex, offsetBy: typed.count)..<shown.endIndex
    }

    /// Takes the field's new text. Typing forward completes it from `candidates`; deleting never does, so Delete
    /// can remove a completion. Returns whether ``shown`` now differs from `text`, so the field must show it.
    public mutating func fieldChanged(to text: String, candidates: [Tab]) -> Bool {
        guard text != shown else { return false }
        let isDeleting = text.count <= typed.count
        typed = text
        shown = text
        guard !isDeleting, let completed = AddressAutocomplete.completion(for: text, in: candidates) else {
            return false
        }
        shown = completed
        return true
    }
}
