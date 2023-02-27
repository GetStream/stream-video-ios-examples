//
//  CustomViews.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 20.2.23.
//

import Foundation
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct CustomParticipantViewModifier: ViewModifier {
    
    @ObservedObject var reactionsHelper = ReactionsHelper.shared
        
    var participant: CallParticipant
    var participantCount: Int
    var availableSize: CGSize
    var ratio: CGFloat
    
    func body(content: Content) -> some View {
        content
            .modifier(
                VideoCallParticipantModifier(
                    participant: participant,
                    participantCount: participantCount,
                    availableSize: availableSize,
                    ratio: ratio
                )
            )
            .overlay(
                ZStack {
                    reactionsHelper.raisedHandsIds.contains(participant.userId) ? BottomRightView {
                        ReactionIcon(iconName: "hand.raised.fill")
                            .padding()
                    } : nil
                    reactionsHelper.likeReactionIds.contains(participant.userId) && !reactionsHelper.raisedHandsIds.contains(participant.userId) ? BottomRightView {
                        ReactionIcon(iconName: "hand.thumbsup.fill")
                            .padding()
                    } : nil
                }
            )
            .onChange(of: participant.isSpeaking) { newValue in
                if newValue {
                    reactionsHelper.removeRaisedHand(from: participant.userId)
                }
            }
    }
    
}
