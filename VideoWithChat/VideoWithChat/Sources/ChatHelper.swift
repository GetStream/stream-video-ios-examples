//
//  ChatHelper.swift
//  VideoWithChat
//
//  Created by Martin Mitrevski on 15.11.22.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class ChatHelper: ObservableObject, ChatChannelControllerDelegate {
    
    @Injected(\.chatClient) var chatClient
    
    @Published var chatShown = false
    
    @Published var channelController: ChatChannelController?
    
    @Published var unreadCount: Int = 0
    
    public var callId: String? {
        didSet {
            guard let callId, channelController == nil else { return }
            channelController = chatClient.channelController(for: .init(type: .custom("videocall"), id: callId))
            channelController?.synchronize()
            channelController?.delegate = self
        }
    }
    
    func channelController(_ channelController: ChatChannelController, didUpdateChannel channel: EntityChange<ChatChannel>) {
        unreadCount = channelController.channel?.unreadCount.messages ?? 0
    }
    
    func markAsRead() {
        channelController?.markRead()
        unreadCount = 0
    }
        
}
