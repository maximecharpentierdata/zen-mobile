import SwiftUI
import ZenModel

/// The space's icon and name at the top of the space screen, with its options menu (spec §3.2, §3.7).
struct SpaceHeader: View {
    let space: Space
    let canMoveLeft: Bool
    let canMoveRight: Bool
    let canDelete: Bool
    let hasRecentlyClosed: Bool
    let autoCloseDelay: AutoCloseDelay
    let onAction: @MainActor (SpaceAction) -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.rowPadding) {
            title
            Spacer(minLength: 0)
            options
        }
    }

    private var title: some View {
        HStack(spacing: Theme.Spacing.rowPadding) {
            Text(space.icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.Palette.onAccent)
                .frame(width: Theme.Size.headerIcon, height: Theme.Size.headerIcon)
                .background(Color(hex: space.accentColor), in: .rect(cornerRadius: Theme.Radius.headerIcon))
                .accessibilityHidden(true)
            Text(space.name)
                .font(.title2.bold())
                .foregroundStyle(Theme.Palette.primaryText)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private var autoClosePicker: some View {
        let selection = Binding(get: { autoCloseDelay }, set: { onAction(.setAutoCloseDelay($0)) })
        return Picker("Close inactive tabs after", systemImage: "clock.badge.xmark", selection: selection) {
            ForEach(AutoCloseDelay.allCases, id: \.self) { delay in
                Text(delay.label)
            }
        }
        .pickerStyle(.menu)
    }

    private var options: some View {
        Menu {
            Button("Edit space", systemImage: "pencil") { onAction(.edit(space.id)) }
            Button("New space", systemImage: "plus") { onAction(.newSpace) }
            Section {
                Button("Move left", systemImage: "arrow.left") { onAction(.moveLeft(space.id)) }
                    .disabled(!canMoveLeft)
                Button("Move right", systemImage: "arrow.right") { onAction(.moveRight(space.id)) }
                    .disabled(!canMoveRight)
            }
            Button("Delete space", systemImage: "trash", role: .destructive) { onAction(.delete(space.id)) }
                .disabled(!canDelete)
            Section {
                Button("Recently closed", systemImage: "clock.arrow.circlepath") { onAction(.recentlyClosed) }
                    .disabled(!hasRecentlyClosed)
                autoClosePicker
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.Palette.secondaryText)
                .frame(width: Theme.Size.headerIcon, height: Theme.Size.headerIcon)
                .contentShape(.rect)
        }
        .accessibilityLabel(Text("Space options"))
    }
}
