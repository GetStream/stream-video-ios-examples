//
//  SceneDelegate.swift
//  VideoWithChatUIKit
//
//  Created by Martin Mitrevski on 13.12.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var streamWrapper: StreamWrapper?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: scene)
        guard let window = self.window else { return }
        login(user: UserCredentials.builtInUsers[0])
        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func login(user: UserCredentials) {
        streamWrapper = StreamWrapper(
            apiKey: "us83cfwuhy8n",
            userCredentials: user,
            tokenProvider: { result in
                //TODO: Provide token here.
                result(.success(user.tokenValue))
            }
        )
    }
}

