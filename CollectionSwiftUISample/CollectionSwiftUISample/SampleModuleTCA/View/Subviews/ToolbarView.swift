import SwiftUI

/// Панель с вспомогательными кнопками для управления состоянием
struct ToolbarView: View {
    let actionHandler: (SampleSystem.Action) -> Void

    private let actions: [(SampleSystem.Action, String)] = [
        (.loadItems, "arrow.counterclockwise.circle.fill"),
        (.removeFirst, "delete.left.fill"),
        (.addFirst, "plus.app.fill"),
        (.loadCarousel, "rectangle.stack.fill")
    ]

    var body: some View {
        HStack {
            ForEach(actions, id: \.0) { action in
                Button(
                    action: { actionHandler(action.0) },
                    label: { Image(systemName: action.1) }
                )
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#if DEBUG
#Preview {
    ToolbarView { print($0) }
}
#endif
