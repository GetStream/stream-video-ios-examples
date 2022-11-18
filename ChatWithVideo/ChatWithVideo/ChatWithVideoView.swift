//
//  ChatWithVideoView.swift
//  ChatWithVideo
//
//  Created by Martin Mitrevski on 16.11.22.
//

import StreamChat
import StreamChatSwiftUI
import struct StreamVideoSwiftUI.CallModifier
import class StreamVideo.CallViewModel
import struct StreamVideoSwiftUI.MinimizedCallView
import SwiftUI

struct ChatWithVideoView<Factory: ViewFactory>: View {
    
    @StateObject var callViewModel: CallViewModel
    var viewFactory: Factory
    var channelController: ChatChannelController
    var scrollToMessage: ChatMessage?
    
    var body: some View {
        ChatChannelView(
            viewFactory: viewFactory,
            channelController: channelController,
            messageController: nil,
            scrollToMessage: scrollToMessage
        )
        .navigationBarHidden(callViewModel.callingState != .idle)
    }
}
