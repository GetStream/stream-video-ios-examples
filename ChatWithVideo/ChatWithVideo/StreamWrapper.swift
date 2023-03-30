//
//  StreamWrapper.swift
//  ChatWithVideo
//
//  Created by Martin Mitrevski on 15.11.22.
//

import Foundation
import StreamChat
import StreamChatSwiftUI
import StreamVideo
import StreamVideoSwiftUI

typealias StreamTokenProvider = (@escaping (Result<UserToken, Error>) -> Void) -> Void

class StreamWrapper {
    let chatClient: ChatClient
    let streamChatUI: StreamChat
    let streamVideo: StreamVideo
    let streamVideoUI: StreamVideoUI
    var tokenProvider: StreamTokenProvider
    
    init(
        apiKey: String,
        user: User,
        initialToken: UserToken,
        tokenProvider: @escaping StreamTokenProvider
    ) {
        chatClient = ChatClient(config: .init(apiKeyString: apiKey))
        streamChatUI = StreamChat(chatClient: chatClient)
        self.tokenProvider = tokenProvider
        streamVideo = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: initialToken,
            videoConfig: VideoConfig(),
            tokenProvider: tokenProvider
        )
        streamVideoUI = StreamVideoUI(streamVideo: streamVideo)
        let userInfo = UserInfo.init(
            id: user.id,
            name: user.name,
            imageURL: user.imageURL,
            extraData: [:]
        )
        chatClient.connectUser(userInfo: userInfo) { result in
            tokenProvider { tokenResult in
                switch tokenResult {
                case .success(let userToken):
                    do {
                        let updatedToken = try Token(rawValue: userToken.rawValue)
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
    
}

