//
//  ChatViewFactory.swift
//  ChatWithVideo
//
//  Created by Martin Mitrevski on 15.11.22.
//

import NukeUI
import class StreamVideo.CallViewModel
import struct StreamVideo.User
import StreamChat
import StreamChatSwiftUI
import SwiftUI

class ChatViewFactory: ViewFactory {
    
    @Injected(\.chatClient) var chatClient: ChatClient
    
    private init() {}
    
    static let shared = ChatViewFactory()
    
    @MainActor var callViewModel = CallViewModel(listenToRingingEvents: true)
    
    func makeChannelListHeaderViewModifier(title: String) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: title)
    }
    
    @MainActor
    func makeChannelDestination() -> (ChannelSelectionInfo) -> ChatWithVideoView<ChatViewFactory> {
        { [unowned self] selectionInfo in
            let controller = chatClient.channelController(for: selectionInfo.channel.cid)
            return ChatWithVideoView(
                callViewModel: self.callViewModel,
                viewFactory: self,
                channelController: controller,
                scrollToMessage: selectionInfo.message
            )
        }
    }
    
}

struct CustomChannelModifier: ChannelListHeaderViewModifier {
    
    @Injected(\.chatClient) var chatClient
    
    var title: String
    
    @State var isNewChatShown = false
    @State var logoutAlertShown = false
    
    func body(content: Content) -> some View {
        ZStack {
            content.toolbar {
                CustomChannelHeader(
                    title: title,
                    currentUserController: chatClient.currentUserController(),
                    isNewChatShown: $isNewChatShown,
                    logoutAlertShown: $logoutAlertShown
                )
            }
            .alert(isPresented: $logoutAlertShown) {
                Alert(
                    title: Text("Sign out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign out")) {
                        withAnimation {
                            chatClient.disconnect()
                            AppState.shared.userState = .notLoggedIn
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}


public struct CustomChannelHeader: ToolbarContent {
    
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    var title: String
    var currentUserController: CurrentChatUserController
    @Binding var isNewChatShown: Bool
    @Binding var logoutAlertShown: Bool
    
    @MainActor
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(fonts.bodyBold)
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                logoutAlertShown = true
            } label: {
                LazyImage(url: currentUserController.currentUser?.imageURL)
                    .onDisappear(.cancel)
                    .clipShape(Circle())
                    .frame(
                        width: 30,
                        height: 30
                    )
            }
        }
    }
}

struct ChannelTitleView: View {
    
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient
    
    var channel: ChatChannel
    var shouldShowTypingIndicator: Bool
    
    private var currentUserId: String {
        chatClient.currentUserId ?? ""
    }
    
    private var channelNamer: ChatChannelNamer {
        utils.channelNamer
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(channelNamer(channel, currentUserId) ?? "")
                .font(fonts.bodyBold)
            
            if shouldShowTypingIndicator {
                HStack {
                    TypingIndicatorView()
                    SubtitleText(text: channel.typingIndicatorString(currentUserId: currentUserId))
                }
            } else {
                Text(channel.onlineInfoText(currentUserId: currentUserId))
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
    }
}
