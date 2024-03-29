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
    @StateObject private var filtersService = FiltersService()
    
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    public init(viewModel: CallViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            EqualSpacingHStack(views: [
                AnyView(
                    ToggleChatButton(chatHelper: chatHelper)
                ),
                AnyView(
                    Button(
                        action: {
                            withAnimation {
                                filtersService.filtersShown.toggle()
                            }
                        },
                        label: {
                            CallIconView(
                                icon: Image(systemName: "camera.filters"),
                                size: size,
                                iconStyle: filtersService.filtersShown ? .primary : .transparent
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
            
            if filtersService.filtersShown {
                HStack(spacing: 16) {
                    ForEach(FiltersService.supportedFilters) { filter in
                        Button {
                            withAnimation {
                                if filtersService.selectedFilter == filter {
                                    filtersService.selectedFilter = nil
                                } else {
                                    filtersService.selectedFilter = filter
                                }
                                viewModel.setVideoFilter(filtersService.selectedFilter)
                            }
                        } label: {
                            Text(filter.name)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(filtersService.selectedFilter == filter ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }

                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: chatHelper.chatShown ? chatHeight + 120 : 120)
        .background(
            colors.callControlsBackground
                .cornerRadius(16)
                .edgesIgnoringSafeArea(.all)
        )
        .onReceive(viewModel.$call) { call in
            chatHelper.callId = call?.callId
        }
    }
    
    private var chatHeight: CGFloat {
        (UIScreen.main.bounds.height / 3 + 50)
    }
    
}

struct ToggleChatButton: View {

    @ObservedObject var chatHelper: ChatHelper

    var body: some View {
        Button {
            // highlight-next-line
            // 1. Toggle chat window
            withAnimation {
                chatHelper.chatShown.toggle()
            }
        }
        label: {
            // highlight-next-line
            // 2. Show button
            CallIconView(
                icon: Image(systemName: "message"),
                size: 50,
                iconStyle: chatHelper.chatShown ? .primary : .transparent
            )
            // highlight-next-line
            // 3. Overlay unread indicator
            .overlay(
                chatHelper.unreadCount > 0 ?
                TopRightView(content: {
                    UnreadIndicatorView(unreadCount: chatHelper.unreadCount)
                })
                : nil
            )
        }
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
