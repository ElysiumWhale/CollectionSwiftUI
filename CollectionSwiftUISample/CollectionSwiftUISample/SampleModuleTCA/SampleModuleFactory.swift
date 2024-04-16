import ComposableArchitecture
import Combine
import UIKit

enum SampleModuleFactory {
    static func make() -> UIViewController {
        let store = Store(
            initialState: SampleSystem.State(),
            reducer: {
                SampleSystem()
            }
        )
        let ui = SampleViewController(store: store)
        return ui
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17, *)
#Preview {
    SampleModuleFactory.make()
}
#endif
