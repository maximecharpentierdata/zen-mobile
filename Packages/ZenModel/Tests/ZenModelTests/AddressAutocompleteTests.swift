import Foundation
import Testing

@testable import ZenModel

@Suite struct AddressAutocompleteTests {
    private func page(_ address: String, title: String = "") -> Tab {
        Tab(url: URL(string: address), title: title, lastAccessed: Fixtures.now)
    }

    private func suggested(_ text: String, in candidates: [Tab]) -> [String] {
        AddressAutocomplete.suggestions(for: text, in: candidates).compactMap(\.url?.absoluteString)
    }

    @Test func displayAddressDropsSchemeWWWAndTrailingSlash() throws {
        let url = try #require(URL(string: "https://www.example.com/"))
        #expect(AddressAutocomplete.displayAddress(of: url) == "example.com")
        let deep = try #require(URL(string: "http://news.example.org/today?a=b"))
        #expect(AddressAutocomplete.displayAddress(of: deep) == "news.example.org/today?a=b")
    }

    @Test func addressPrefixMatchesComeFirst() {
        let candidates = [
            page("https://example.com/github", title: "Mirror"),
            page("https://docs.example.com", title: "GitHub notes"),
            page("https://github.com/zen", title: "Zen"),
        ]
        #expect(
            suggested("git", in: candidates) == [
                "https://github.com/zen", "https://example.com/github", "https://docs.example.com",
            ])
    }

    @Test func matchingIgnoresCaseSchemeAndWWW() {
        let candidates = [page("https://www.github.com/zen")]
        #expect(suggested("GitHub", in: candidates) == ["https://www.github.com/zen"])
        #expect(suggested("https://www.git", in: candidates) == ["https://www.github.com/zen"])
    }

    @Test func sameURLIsSuggestedOnce() {
        let candidates = [page("https://github.com", title: "One"), page("https://github.com", title: "Two")]
        let suggestions = AddressAutocomplete.suggestions(for: "git", in: candidates)
        #expect(suggestions.map(\.title) == ["One"])
    }

    @Test func blankTextAndTabsWithoutAddressGiveNothing() {
        let candidates = [page("https://github.com"), Tab(title: "github", lastAccessed: Fixtures.now)]
        #expect(suggested("  ", in: candidates).isEmpty)
        #expect(suggested("git", in: candidates) == ["https://github.com"])
    }

    @Test func suggestionsAreLimited() {
        let candidates = (0..<10).map { page("https://example.com/\($0)") }
        let suggestions = AddressAutocomplete.suggestions(for: "example", in: candidates)
        #expect(suggestions.count == AddressAutocomplete.suggestionLimit)
    }

    @Test func completionFinishesTheHostFirst() {
        let candidates = [page("https://www.github.com/zen/browser")]
        #expect(AddressAutocomplete.completion(for: "git", in: candidates) == "github.com")
        #expect(AddressAutocomplete.completion(for: "GIT", in: candidates) == "GIThub.com")
        #expect(AddressAutocomplete.completion(for: "www.git", in: candidates) == "www.github.com")
    }

    @Test func completionFinishesThePathOnceASlashIsTyped() {
        let candidates = [page("https://github.com/zen/browser")]
        #expect(AddressAutocomplete.completion(for: "github.com/z", in: candidates) == "github.com/zen/browser")
    }

    @Test func noCompletionWithoutAnAddressPrefixMatch() {
        let candidates = [page("https://github.com", title: "Where the code is")]
        #expect(AddressAutocomplete.completion(for: "code", in: candidates) == nil)
        #expect(AddressAutocomplete.completion(for: "github.com", in: candidates) == nil)
        #expect(AddressAutocomplete.completion(for: "git ", in: candidates) == nil)
        #expect(AddressAutocomplete.completion(for: "", in: candidates) == nil)
    }
}
