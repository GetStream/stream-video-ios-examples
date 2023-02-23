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
        .overlay(
            callViewModel.callingState == .inCall ? InCallView(callViewModel: callViewModel) : nil
        )
        .navigationBarHidden(callViewModel.callingState != .idle)
    }
}

struct InCallView: View {
    
    @StateObject var callViewModel: CallViewModel
    
    var body: some View {
        VStack {
            Button {
                callViewModel.isMinimized = false
            } label: {
                HStack {
                    Text("Video call ongoing")
                        .font(.headline)
                    Spacer()
                    HStack {
                        Image(systemName: "video.fill")
                        Text("Open")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.primary)

            Spacer()
        }

    }
    
}
