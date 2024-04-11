import ComposableArchitecture
import UIKit
import Combine

enum MainModuleFactory {
    static func make() -> (ui: UIViewController, output: AnyPublisher<MainSystem.Output, Never>) {
        let output = PassthroughSubject<MainSystem.Output, Never>()
        let env = MainSystem.Environment(output: output.send)
        let store = Store(
            initialState: MainSystem.State(),
            reducer: {
                MainSystem(env: env)
            }
        )
        let viewStore = ViewStore(store, observe: { $0 })
        let ui = MainViewController(viewStore: viewStore)
        return (ui, output.eraseToAnyPublisher())
    }
}
