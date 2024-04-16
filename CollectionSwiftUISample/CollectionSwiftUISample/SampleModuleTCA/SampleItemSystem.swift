import ComposableArchitecture

struct SampleItemSystem: Reducer {
    struct State: Identifiable, Equatable {
        let id: Int
        var isCollapsed = true
    }

    enum Action: Hashable {
        case setCollapsed(Bool)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setCollapsed(value):
            state.isCollapsed = value
            return .none
        }
    }
}
