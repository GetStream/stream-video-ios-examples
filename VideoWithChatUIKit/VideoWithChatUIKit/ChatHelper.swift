//
//  ChatHelper.swift
//  VideoWithChatUIKit
//
//  Created by Martin Mitrevski on 13.12.22.
//

import Foundation
import StreamChat
import StreamChatSwiftUI
import SwiftUI

class ChatHelper: ObservableObject, ChatChannelControllerDelegate {
    
    @Injected(\.chatClient) var chatClient
    
    @Published var chatShown = false
    
    @Published var channelController: ChatChannelController?
    
    @Published var unreadCount: Int = 0
    
    private var memberIds = Set<String>() {
        didSet {
            channelController = try? chatClient.channelController(
                createDirectMessageChannelWith: memberIds,
                extraData: [:]
            )
            channelController?.synchronize()
            channelController?.delegate = self
        }
    }
    
    func update(memberIds: Set<String>) {
        self.memberIds = memberIds
    }
    
    func channelController(_ channelController: ChatChannelController, didUpdateChannel channel: EntityChange<ChatChannel>) {
        unreadCount = channelController.channel?.unreadCount.messages ?? 0
    }
    
    func markAsRead() {
        channelController?.markRead()
        unreadCount = 0
    }
        
}
