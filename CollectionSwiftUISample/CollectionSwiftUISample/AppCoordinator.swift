import UIKit
import Combine

final class AppCoordinator {
    private let window: UIWindow

    private var cancellables = Set<AnyCancellable>()

    private let tabBar = UITabBarController()
    private let router = UINavigationController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let main = makeMainModule()

        router.tabBarItem.title = "Main"
        router.tabBarItem.image = UIImage(systemName: "newspaper")
        router.tabBarItem.selectedImage = UIImage(systemName: "newspaper.fill")

        router.setViewControllers([main], animated: true)
        tabBar.setViewControllers([router], animated: false)

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
