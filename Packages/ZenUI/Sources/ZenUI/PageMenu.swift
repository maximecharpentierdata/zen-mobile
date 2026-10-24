import SwiftUI
import UIKit
import ZenWeb

/// The "…" button beside the page bar, with the classic browser options (spec §3.4).
struct PageMenu: View {
    let url: URL?
    let navigation: PageNavigation

    var body: some View {
        Menu {
            Section {
                Button("Back", systemImage: "chevron.backward") { navigation.goBack() }
                    .disabled(!navigation.canGoBack)
                Button("Forward", systemImage: "chevron.forward") { navigation.goForward() }
                    .disabled(!navigation.canGoForward)
                Button("Reload", systemImage: "arrow.clockwise") { navigation.reload() }
                    .disabled(url == nil)
            }
            if let url {
                Section {
                    ShareLink(item: url)
                    Button("Copy link", systemImage: "link") { UIPasteboard.general.url = url }
                }
                Section {
                    Button("Find on page", systemImage: "magnifyingglass") { navigation.findOnPage() }
                    desktopSiteButton
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.Palette.primaryText)
                .frame(width: Theme.Size.pageBarHeight, height: Theme.Size.pageBarHeight)
                .background(Theme.Palette.pageBarFill, in: .circle)
                .contentShape(.circle)
        }
        .accessibilityLabel(Text("Page options"))
    }

    private var desktopSiteButton: some View {
        let title: LocalizedStringKey = navigation.isDesktopSite ? "Request mobile site" : "Request desktop site"
        let icon = navigation.isDesktopSite ? "iphone" : "desktopcomputer"
        return Button(title, systemImage: icon) { navigation.toggleDesktopSite() }
    }
}
