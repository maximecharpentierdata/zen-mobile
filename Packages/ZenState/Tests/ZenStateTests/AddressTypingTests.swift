import Foundation
import Testing
import ZenModel

@testable import ZenState

@Suite struct AddressTypingTests {
    private let candidates = [
        Tab(url: URL(string: "https://github.com/zen"), lastAccessed: Date(timeIntervalSince1970: 0))
    ]

    @Test func startsWithTheTextAndNoCompletion() {
        let typing = AddressTyping(text: "https://example.com")
        #expect(typing.typed == "https://example.com")
        #expect(typing.shown == "https://example.com")
        #expect(typing.completionRange == nil)
    }

    @Test func typingForwardShowsTheCompletionAfterTheTypedText() throws {
        var typing = AddressTyping(text: "")
        #expect(typing.fieldChanged(to: "gi", candidates: candidates))
        #expect(typing.typed == "gi")
        #expect(typing.shown == "github.com")
        let range = try #require(typing.completionRange)
        #expect(typing.shown[range] == "thub.com")
    }

    @Test func theFieldEchoingTheCompletionChangesNothing() {
        var typing = AddressTyping(text: "")
        _ = typing.fieldChanged(to: "gi", candidates: candidates)
        #expect(!typing.fieldChanged(to: "github.com", candidates: candidates))
        #expect(typing.typed == "gi")
    }

    @Test func deletingTheCompletionDoesNotBringItBack() {
        var typing = AddressTyping(text: "")
        _ = typing.fieldChanged(to: "gi", candidates: candidates)
        #expect(!typing.fieldChanged(to: "gi", candidates: candidates))
        #expect(typing.shown == "gi")
        #expect(typing.completionRange == nil)
        #expect(!typing.fieldChanged(to: "g", candidates: candidates))
        #expect(typing.shown == "g")
    }

    @Test func typingOverTheCompletionCompletesAgain() {
        var typing = AddressTyping(text: "")
        _ = typing.fieldChanged(to: "gi", candidates: candidates)
        #expect(typing.fieldChanged(to: "git", candidates: candidates))
        #expect(typing.typed == "git")
        #expect(typing.shown == "github.com")
    }

    @Test func textWithoutAMatchIsShownAsTyped() {
        var typing = AddressTyping(text: "")
        #expect(!typing.fieldChanged(to: "zz", candidates: candidates))
        #expect(typing.shown == "zz")
        #expect(typing.completionRange == nil)
    }
}
