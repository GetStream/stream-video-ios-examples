//
//  SceneDelegate.swift
//  ChatWithVideoUIKit
//
//  Created by Martin Mitrevski on 22.11.22.
//

import UIKit
import struct StreamVideo.User
import StreamChat

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        self.window = UIWindow(windowScene: scene)
        
        let userId = "martin"
        Task {
            let token = try await TokenService.shared.fetchToken(for: userId)
            /// user id and token for the user
            let user = User(
                id: userId,
                name: "Martin",
                imageURL: URL(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/802d2/martin-mitrevski.webp"),
                extraData: [:])
            let userCredentials = UserCredentials(
                user: user,
                tokenValue: token.rawValue
            )
            
            StreamWrapper.shared = StreamWrapper(
                apiKey: "hd8szvscpxvd",
                userCredentials: userCredentials,
                tokenProvider: { result in
                    Task {
                        do {
                            let token = try await TokenService.shared.fetchToken(for: user.id)
                            result(.success(token.rawValue))
                        } catch {
                            result(.failure(error))
                        }
                    }
            })
            
            let channelList = ChannelListViewController()
            let query = ChannelListQuery(filter: .containMembers(userIds: [userId]))
            channelList.controller = StreamWrapper.shared.chatClient.channelListController(query: query)
            
            window?.rootViewController = UINavigationController(rootViewController: channelList)
            window?.makeKeyAndVisible()
        }

    }
    
}

