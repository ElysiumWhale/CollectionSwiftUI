import SwiftUI
import TipKit

struct ToolbarTip: Tip {
    let id = "ToolbarTip"

    var title: Text {
        Text("Описание панели инструментов")
    }

    var message: Text? {
        Text(
            """
            1. Перезагрузка элементов списка
            2. Удаление элемента списка из начала
            3. Добавление элемента списка в начало
            4. Загрузка карусели (изначально не загружена)
            """
        )
    }
}

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
        .tipIfAvaialbe()
    }

    init(actionHandler: @escaping (SampleSystem.Action) -> Void) {
        self.actionHandler = actionHandler
        if #available(iOS 17.0, *) {
            try? Tips.resetDatastore()
            try? Tips.configure()
        }
    }
}

extension View {
    @ViewBuilder
    func tipIfAvaialbe() -> some View {
        if #available(iOS 17.0, *) {
            popoverTip(ToolbarTip())
        } else {
            self
        }
    }
}

#if DEBUG
#Preview {
    ToolbarView { print($0) }
}
#endif
