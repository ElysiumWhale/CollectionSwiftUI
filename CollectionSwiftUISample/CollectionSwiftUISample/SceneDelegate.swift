//
//  SceneDelegate.swift
//  CollectionSwiftUISample
//
//  Created by Gurin on 11.04.24.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)

        let main = MainViewController()
        let navigation = UINavigationController(rootViewController: main)
        navigation.tabBarItem.title = "Main"
        navigation.tabBarItem.image = UIImage(systemName: "newspaper")
        navigation.tabBarItem.selectedImage = UIImage(systemName: "newspaper.fill")

        let tabBar = UITabBarController()
        tabBar.setViewControllers([navigation], animated: false)

        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}
