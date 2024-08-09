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
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiSGFuX1NvbG8iLCJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0hhbl9Tb2xvIiwiaWF0IjoxNzIzMjAzMzI1LCJleHAiOjE3MjM4MDgxMzB9.pgvj7BaR47f4mIvaZnrOUxccDgZZQB3CPbZ90e5HUsY"
        } else if userId == "Kir_Kanos" {
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiS2lyX0thbm9zIiwiaXNzIjoiaHR0cHM6Ly9wcm9udG8uZ2V0c3RyZWFtLmlvIiwic3ViIjoidXNlci9LaXJfS2Fub3MiLCJpYXQiOjE3MjI5NDI2OTgsImV4cCI6MTcyMzU0NzUwM30.Y-B4b_KqgMcUR_OGUyylEJA_pKlWvwr9H4sI1uy7PJk"
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
