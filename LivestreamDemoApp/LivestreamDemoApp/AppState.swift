//
//  AppState.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 9.8.24.
//

import Foundation
import StreamChat
import StreamVideo

class AppState {
    static let shared = AppState()
    
    private init() {}
    
    var streamVideo: StreamVideo?
    var chatClient: ChatClient?
    
    func connect(userId: String) {
        let apiKey = "mmhfdzb5evj2"
        let userToken = token(for: userId)
        
        let user = User(id: userId, name: userId)
        
        let streamVideo = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(rawValue: userToken)
        )
        self.streamVideo = streamVideo
                
        let chatClient = ChatClient(config: .init(apiKey: .init(apiKey)))
        self.chatClient = chatClient
     
        let token = try! Token(rawValue: userToken)
        chatClient.connectUser(
            userInfo: .init(
                id: userId,
                name: userId,
                imageURL: imageURL(for: userId)
            ),
            tokenProvider: { result in
                result(.success(token))
            }
        ) { error in
            if let error {
                print("error connecting to the chat client \(error.localizedDescription)")
            }
        }
    }
    
    private func token(for userId: String) -> String {
        if userId == "Han_Solo" {
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiSGFuX1NvbG8ifQ.ZcRRH9xA6IpxGJmBTLv4cM341cQI_vwhNqcPnq3X5eA"
        } else if userId == "Kir_Kanos" {
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiS2lyX0thbm9zIn0.g8lXbYnzGxNwteQbxoEOOjcEofOIa3Xgt3IT4S-TBg4"
        } else {
            return ""
        }
    }
    
    private func imageURL(for userId: String) -> URL? {
        if userId == "Han_Solo" {
            return URL(string: "https://vignette.wikia.nocookie.net/starwars/images/e/e2/TFAHanSolo.png")
        } else if userId == "Kir_Kanos" {
            return URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")
        } else {
            return nil
        }
    }
}
