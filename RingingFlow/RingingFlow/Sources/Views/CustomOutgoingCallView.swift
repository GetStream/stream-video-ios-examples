//
//  CustomOutgoingCallView.swift
//  RingingFlow
//
//  Created by Ilias Pavlidakis on 9/5/24.
//

import Foundation
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct CustomOutgoingCallView<CallControls: View, CallTopView: View>: View {

    @Injected(\.streamVideo) var streamVideo

    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    @Injected(\.utils) var utils

    var viewModel: CallViewModel
    var outgoingCallMembers: [Member]
    var callTopView: CallTopView
    var callControls: CallControls

    @State var isRinging: Bool = false

    public init(
        viewModel: CallViewModel,
        outgoingCallMembers: [Member],
        callTopView: CallTopView,
        callControls: CallControls
    ) {
        self.viewModel = viewModel
        self.outgoingCallMembers = outgoingCallMembers
        self.callTopView = callTopView
        self.callControls = callControls
    }

    public var body: some View {
        CallConnectingView(
            outgoingCallMembers: outgoingCallMembers,
            title: isRinging ? "Ringing" : "Calling",
            callControls: callControls,
            callTopView: callTopView
        )
        .onAppear {
            utils.callSoundsPlayer.playOutgoingCallSound()
        }
        .onDisappear {
            utils.callSoundsPlayer.stopOngoingSound()
        }
        .task {
            for await event in streamVideo.subscribe(for: CallSessionParticipantJoinedEvent.self) {
                guard event.participant.user.id != streamVideo.user.id else {
                    return
                }
                isRinging = true
            }
        }
        .task {
            guard let call = viewModel.call else {
                return
            }
            log.debug("Observing isAlive customVideoEvent.")
            for await event in call.subscribe(for: CustomVideoEvent.self) {
                guard
                    event.custom[CustomEvent.isAlive.rawValue] != nil
                else {
                    return
                }
                Task { @MainActor in
                    isRinging = true
                }
            }
        }
    }
}
