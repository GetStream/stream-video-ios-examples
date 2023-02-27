//
//  CustomCallControls.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 17.2.23.
//

import EffectsLibrary
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct CustomCallControls: View {
    
    @Injected(\.streamVideo) var streamVideo
    
    private let size: CGFloat = 50
    
    @ObservedObject var viewModel: CallViewModel
    @ObservedObject var reactionsHelper = ReactionsHelper.shared
    @StateObject var permissionsHelper = PermissionsHelper()
    
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    public init(
        viewModel: CallViewModel
    ) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            EqualSpacingHStack(views: [
                AnyView(
                    ToggleReactionsButton(reactionsHelper: reactionsHelper)
                ),
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
            .padding(.top, reactionsHelper.reactionsShown ? 16 : 0)
            
            if reactionsHelper.reactionsShown {
                Spacer()
                
                HStack(spacing: 32) {
                    ForEach(reactionsHelper.availableReactions) { reaction in
                        Button {                            
                            reactionsHelper.send(reaction: reaction)
                        } label: {
                            ReactionIcon(iconName: reaction.iconName)
                        }
                    }
                }

                Spacer()
            } else if permissionsHelper.showAdminControls, let callId = viewModel.call?.callId {
                HStack(spacing: 16) {
                    if permissionsHelper.currentUserCanMuteUsers {
                        Button {
                            permissionsHelper.muteUsers(
                                ids: viewModel.callParticipants.values.map(\.userId),
                                callId: callId,
                                callType: viewModel.call?.callType ?? .default
                            )
                        } label: {
                            Text("Mute all")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    if permissionsHelper.currentUserCanEndCall {
                        Button {
                            permissionsHelper.endCallForEveryone(callId: callId, callType: viewModel.call?.callType ?? .default)
                        } label: {
                            Text("End call for all")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: reactionsHelper.reactionsShown ? reactionsHeight + 120 : (permissionsHelper.showAdminControls ? 150 : 120))
        .background(
            colors.callControlsBackground
                .cornerRadius(16)
                .edgesIgnoringSafeArea(.all)
        )
        .onReceive(viewModel.$call) { call in
            reactionsHelper.callId = call?.callId
            reactionsHelper.callType = call?.callType
        }
    }
    
    private var reactionsHeight: CGFloat {
        (UIScreen.main.bounds.height / 4)
    }
    
}

struct ReactionIcon: View {
    
    var iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40)
            .foregroundColor(Color.yellow)
    }
    
}

struct ToggleReactionsButton: View {

    @ObservedObject var reactionsHelper: ReactionsHelper

    var body: some View {
        Button {
            withAnimation {
                reactionsHelper.reactionsShown.toggle()
            }
        }
        label: {
            CallIconView(
                icon: Image(systemName: "bolt.fill"),
                size: 50,
                iconStyle: reactionsHelper.reactionsShown ? .primary : .transparent
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
