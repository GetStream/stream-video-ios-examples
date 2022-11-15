//
//  ChatCallControls.swift
//  VideoWithChat
//
//  Created by Martin Mitrevski on 14.11.22.
//

import SwiftUI
import struct StreamChatSwiftUI.ChatChannelView
import struct StreamChatSwiftUI.UnreadIndicatorView
import StreamVideo
import StreamVideoSwiftUI

struct ChatCallControls: View {
    
    @Injected(\.streamVideo) var streamVideo
    
    private let size: CGFloat = 50
    
    @ObservedObject var viewModel: CallViewModel
    
    @StateObject private var chatHelper = ChatHelper()
    
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    public init(viewModel: CallViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            EqualSpacingHStack(views: [
                AnyView(
                    Button(
                        action: {
                            withAnimation {
                                chatHelper.chatShown.toggle()
                            }
                        },
                        label: {
                            CallIconView(
                                icon: Image(systemName: "message"),
                                size: size,
                                iconStyle: chatHelper.chatShown ? .primary : .transparent
                            )
                            .overlay(
                                chatHelper.unreadCount > 0 ?
                                    TopRightView(content: {
                                        UnreadIndicatorView(unreadCount: chatHelper.unreadCount)
                                    })
                                : nil
                            )
                        }
                    )),
                AnyView(
                    Button(
                        action: {
                            viewModel.toggleCameraEnabled()
                        },
                        label: {
                            CallIconView(
                                icon: (viewModel.callSettings.videoOn ? images.videoTurnOn : images.videoTurnOff),
                                size: size,
                                iconStyle: (viewModel.callSettings.videoOn ? .primary : .transparent)
                            )
                        }
                    )),
                AnyView(Button(
                    action: {
                        viewModel.toggleMicrophoneEnabled()
                    },
                    label: {
                        CallIconView(
                            icon: (viewModel.callSettings.audioOn ? images.micTurnOn : images.micTurnOff),
                            size: size,
                            iconStyle: (viewModel.callSettings.audioOn ? .primary : .transparent)
                        )
                    }
                )),
                AnyView(Button(
                    action: {
                        viewModel.toggleCameraPosition()
                    },
                    label: {
                        CallIconView(
                            icon: images.toggleCamera,
                            size: size,
                            iconStyle: .primary
                        )
                    }
                )),
                AnyView(Button {
                    viewModel.hangUp()
                } label: {
                    images.hangup
                        .applyCallButtonStyle(
                            color: colors.hangUpIconColor,
                            size: size
                        )
                })
            ])
            
            if chatHelper.chatShown {
                if let channelController = chatHelper.channelController {
                    ChatChannelView(viewFactory: ChatViewFactory.shared, channelController: channelController)
                        .frame(height: chatHeight)
                        .preferredColorScheme(.dark)
                        .onAppear {
                            chatHelper.markAsRead()
                        }
                } else {
                    Spacer()
                    Text("Chat not available")
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: chatHelper.chatShown ? chatHeight + 100 : 100)
        .background(
            colors.callControlsBackground
                .cornerRadius(16)
                .edgesIgnoringSafeArea(.all)
        )
        .onReceive(viewModel.$callParticipants, perform: { output in
            if viewModel.callParticipants.count > 1 {
                chatHelper.update(memberIds: Set(viewModel.callParticipants.map(\.key)))
            }
        })
    }
    
    private var chatHeight: CGFloat {
        (UIScreen.main.bounds.height / 3 + 50)
    }
    
}

struct EqualSpacingHStack: View {
    
    var views: [AnyView]
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(0..<views.count, id:\.self) { index in
                Spacer()
                views[index]
                Spacer()
            }
        }
    }
    
}
