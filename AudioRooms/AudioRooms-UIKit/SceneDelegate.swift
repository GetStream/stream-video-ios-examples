//
//  SceneDelegate.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ContentViewController()
        self.window = window

        window.makeKeyAndVisible()
    }
}
