import UIKit
import Combine

final class AppCoordinator {
    private let window: UIWindow

    private var cancellables = Set<AnyCancellable>()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let main = makeMainModule()
        let navigation = UINavigationController(rootViewController: main)
        navigation.tabBarItem.title = "Main"
        navigation.tabBarItem.image = UIImage(systemName: "newspaper")
        navigation.tabBarItem.selectedImage = UIImage(systemName: "newspaper.fill")

        let tabBar = UITabBarController()
        tabBar.setViewControllers([navigation], animated: false)

        window.rootViewController = tabBar
        window.makeKeyAndVisible()
    }

    private func makeMainModule() -> UIViewController {
        let module = MainModuleFactory.make()

        module.output
            .sink { _ in

            }
            .store(in: &cancellables)

        return module.ui
    }
}
