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
        /// user id and token for the user
        let userId = "tommaso"
        let user = User(
            id: userId,
            name: "Tommaso",
            imageURL: URL(string: "https://getstream.io/static/712bb5c0bd5ed8d3fa6e5842f6cfbeed/c59de/tommaso.webp"),
            extraData: [:])
        let userCredentials = UserCredentials(
            user: user,
            videoTokenValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tanNAdjAuMC4wIiwic3ViIjoidXNlci90b21tYXNvIiwiaWF0IjoxNjY4MDc4MDEsInVzZXJfaWQiOiJ0b21tYXNvIn0.lOzf0aZ80tKR438N6H5usitSJoWNy97zY1mT8xcXujc",
            chatTokenValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidG9tbWFzbyJ9.BR8YNU3H-l19anEPyqOV_-QMjuiHuHrTlSxURuhhUww"
        )
        
        StreamWrapper.shared = StreamWrapper(
            chatApiKey: "zcgvnykxsfm8",
            videoApiKey: "key10",
            userCredentials: userCredentials,
            tokenProvider: { result in
            result(.success(userCredentials.videoTokenValue))
        })        
        
        let channelList = ChannelListViewController()
        let query = ChannelListQuery(filter: .containMembers(userIds: [userId]))
        channelList.controller = StreamWrapper.shared.chatClient.channelListController(query: query)
        
        window?.rootViewController = UINavigationController(rootViewController: channelList)
        window?.makeKeyAndVisible()
    }
    
}

