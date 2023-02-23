//
//  StreamWrapper.swift
//  ChatWithVideoUIKit
//
//  Created by Martin Mitrevski on 22.11.22.
//

import Foundation
import StreamChat
import StreamVideo
import StreamVideoSwiftUI
import StreamVideoUIKit
import StreamChatUI

typealias StreamTokenProvider = (@escaping (Result<String, Error>) -> Void) -> Void

class StreamWrapper {
    let chatClient: ChatClient
    let streamVideo: StreamVideo
    let streamVideoUI: StreamVideoUI
    var tokenProvider: StreamTokenProvider
    
    init(
        apiKey: String,
        userCredentials: UserCredentials,
        tokenProvider: @escaping StreamTokenProvider
    ) {
        Self.applyChatCustomizations()
        chatClient = ChatClient(config: .init(apiKeyString: apiKey))
        self.tokenProvider = tokenProvider
        let token = userCredentials.videoToken
        streamVideo = StreamVideo(
            apiKey: apiKey,
            user: userCredentials.user,
            token: token,
            videoConfig: VideoConfig(
                ringingTimeout: 0
            ),
            tokenProvider: { result in
                tokenProvider { tokenResult in
                    switch tokenResult {
                    case .success(let rawValue):
                        do {
                            let updatedToken = try UserToken(rawValue: rawValue)
                            result(.success(updatedToken))
                        } catch {
                            result(.failure(error))
                        }
                    case .failure(let error):
                        result(.failure(error))
                    }
                }
            }
        )
        streamVideoUI = StreamVideoUI(streamVideo: streamVideo)
        let userInfo = UserInfo.init(
            id: userCredentials.user.id,
            name: userCredentials.user.name,
            imageURL: userCredentials.user.imageURL,
            extraData: [:]
        )
        chatClient.connectUser(userInfo: userInfo) { result in
            tokenProvider { tokenResult in
                switch tokenResult {
                case .success(let rawValue):
                    do {
                        let updatedToken = try Token(rawValue: rawValue)
                        result(.success(updatedToken))
                    } catch {
                        result(.failure(error))
                    }
                case .failure(let error):
                    result(.failure(error))
                }
            }
        }
    }
    
    static func applyChatCustomizations() {
        Components.default.channelVC = ChatWithVideoViewController.self
        Components.default.channelListRouter = ChannelListRouter.self
    }
}
