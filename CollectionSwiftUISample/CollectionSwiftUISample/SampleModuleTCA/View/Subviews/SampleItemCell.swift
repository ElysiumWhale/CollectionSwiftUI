import SwiftUI
import ComposableArchitecture

/// Ячейка с изменяющейся высотой в завимости от состония
struct SampleItemCell: View {
    @ObservedObject
    private var viewStore: ViewStoreOf<SampleItemSystem>

    var body: some View {
        VStack {
            Button(
                "Hello, World! \(viewStore.id)",
                action: {
                    viewStore.send(.setCollapsed(!viewStore.isCollapsed))
                }
            )
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .shadow(radius: 5)

            if !viewStore.isCollapsed {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
            }
        }
        .animation(.linear, value: viewStore.isCollapsed)
    }

    init(store: StoreOf<SampleItemSystem>) {
        self.viewStore = ViewStore(store, observe: { $0 })
    }
}

#if DEBUG
#Preview {
    SampleItemCell(
        store: Store(
            initialState: SampleItemSystem.State(id: 1),
            reducer: { SampleItemSystem() }
        )
    )
}
#endif
