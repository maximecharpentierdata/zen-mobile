import Foundation
import Testing

@testable import ZenModel

@Suite struct AddressInputTests {
    private func resolve(_ text: String) -> String? {
        AddressInput.url(for: text, engine: .duckDuckGo)?.absoluteString
    }

    @Test func fullURLsAreKept() {
        #expect(resolve("https://example.com/a?b=c") == "https://example.com/a?b=c")
        #expect(resolve("http://example.com") == "http://example.com")
    }

    @Test func hostsGetHTTPS() {
        #expect(resolve("example.com") == "https://example.com")
        #expect(resolve("  news.example.org/today  ") == "https://news.example.org/today")
        #expect(resolve("localhost:8080") == "https://localhost:8080")
    }

    @Test func otherTextIsSearched() {
        #expect(resolve("hiking boots") == "https://duckduckgo.com/?q=hiking%20boots")
        #expect(resolve("hello") == "https://duckduckgo.com/?q=hello")
        #expect(resolve("what is 2.5") == "https://duckduckgo.com/?q=what%20is%202.5")
    }

    @Test func blankTextGivesNothing() {
        #expect(resolve("   ") == nil)
    }
}
