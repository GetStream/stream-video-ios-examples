//
//  LivestreamChatViewModel.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 6.8.24.
//

import SwiftUI
import class StreamVideo.Call
import struct StreamVideo.CallSessionParticipantJoinedEvent
import StreamChat

@MainActor
class LivestreamChatViewModel: ObservableObject, ChatChannelControllerDelegate {
        
    @Published var text = ""
    
    private let livestreamId: String
    
    private let chatClient: ChatClient
    private let channelController: ChatChannelController
    private let call: Call
    
    private var joinEventsTask: Task<Void, Never>?
    
    @Published var messages = [LivestreamMessage]()
    
    private var eventMessages = [LivestreamMessage]() {
        didSet {
            updateMessages()
        }
    }
    
    private let welcomeMessage = LivestreamMessage(
        id: UUID().uuidString,
        text: "Welcome to the livestream",
        imageURL: nil,
        date: .distantPast
    )
    
    private let chatMessagesLimit = 10
    
    init(chatClient: ChatClient, call: Call, livestreamId: String) {
        self.livestreamId = livestreamId
        self.chatClient = chatClient
        self.call = call
        let cid = ChannelId(type: .livestream, id: livestreamId)
        self.channelController = chatClient.channelController(for: cid)
        self.channelController.delegate = self
        self.channelController.synchronize()
        subscribeToJoinEvents()
    }
    
    func sendMessage(text: String) {
        channelController.createNewMessage(text: text)
        self.text = ""
    }
    
    // MARK: - ChatChannelControllerDelegate
    
    nonisolated func channelController(
        _ channelController: ChatChannelController,
        didUpdateMessages changes: [ListChange<ChatMessage>]
    ) {
        Task { @MainActor in
            updateMessages()
        }
    }
    
    // MARK: - private
    
    private func updateMessages() {
        var latestChatMessages = Array(channelController
            .messages
            .map { LivestreamMessage(
                id: $0.id,
                text: $0.text,
                imageURL: $0.author.imageURL,
                date: $0.createdAt
            )
        }
        .prefix(chatMessagesLimit))
        
        latestChatMessages.append(welcomeMessage)
        latestChatMessages.append(contentsOf: eventMessages)
        
        latestChatMessages.sort {
            $0.date > $1.date
        }
        
        messages = Array(latestChatMessages.prefix(chatMessagesLimit)).reversed()
    }
    
    private func subscribeToJoinEvents() {
        joinEventsTask = Task {
            let subscription = call.subscribe(for: CallSessionParticipantJoinedEvent.self)
            for await event in subscription {
                let user = event.participant.user
                let userName = user.name ?? user.id
                var url: URL?
                if let image = user.image {
                    url = URL(string: image)
                }
                let eventMessage = LivestreamMessage(
                    id: UUID().uuidString,
                    text: "\(userName) joined",
                    imageURL: url,
                    date: Date()
                )
                eventMessages.append(eventMessage)
            }
        }
    }

    deinit {
        joinEventsTask?.cancel()
    }
}

struct LivestreamMessage: Identifiable {
    let id: String
    let text: String
    let imageURL: URL?
    let date: Date
}
