//
//  ChatViewFactory.swift
//  VideoWithChatUIKit
//
//  Created by Martin Mitrevski on 13.12.22.
//

import Foundation
import StreamChatSwiftUI
import StreamChat
import SwiftUI

class ChatViewFactory: ViewFactory {
    
    @Injected(\.chatClient) var chatClient: ChatClient
    
    private init() {}
    
    static let shared = ChatViewFactory()
        
}
