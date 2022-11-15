//
//  StreamWrapper.swift
//  VideoWithChat
//
//  Created by Martin Mitrevski on 14.11.22.
//

import Foundation
import StreamChat
import StreamChatSwiftUI
import StreamVideo
import StreamVideoSwiftUI

class StreamWrapper {
    let chatClient: ChatClient
    let streamChatUI: StreamChat
    let streamVideo: StreamVideo
    let streamVideoUI: StreamVideoUI
    
    init(
        chatApiKey: String,
        videoApiKey: String,
        userCredentials: UserCredentials
    ) {
        chatClient = ChatClient(config: .init(apiKeyString: chatApiKey))
        streamChatUI = StreamChat(chatClient: chatClient)
        let token = userCredentials.videoToken
        streamVideo = StreamVideo(
            apiKey: videoApiKey,
            user: userCredentials.user,
            token: token,
            videoConfig: VideoConfig(joinVideoCallInstantly: true),
            tokenProvider: { result in
                //TODO: figure out the token renewal.
                result(.success(token))
            }
        )
        streamVideoUI = StreamVideoUI(streamVideo: streamVideo)
        let chatToken = try! Token(rawValue: userCredentials.chatTokenValue)
        let userInfo = UserInfo.init(
            id: userCredentials.user.id,
            name: userCredentials.user.name,
            imageURL: userCredentials.user.imageURL,
            extraData: [:]
        )
        chatClient.connectUser(userInfo: userInfo, token: chatToken)
    }
    
}

