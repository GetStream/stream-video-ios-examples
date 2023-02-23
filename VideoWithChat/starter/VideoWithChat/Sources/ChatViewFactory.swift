//
//  ChatViewFactory.swift
//  VideoWithChat
//
//  Created by Martin Mitrevski on 14.11.22.
//

import StreamChatSwiftUI
import StreamChat
import SwiftUI

class ChatViewFactory: ViewFactory {
    
    @Injected(\.chatClient) var chatClient: ChatClient
    
    private init() {}
    
    static let shared = ChatViewFactory()
        
}
