import ComposableArchitecture

struct MainSystem: Reducer {
    struct State: Equatable {
    }

    enum Action {
        case showSample
    }

    enum Output {
        case showSample
    }

    struct Environment {
        let output: (Output) -> Void
    }

    let env: Environment

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .showSample:
            return .run { @MainActor _ in
                env.output(.showSample)
            }
        }
    }
}
