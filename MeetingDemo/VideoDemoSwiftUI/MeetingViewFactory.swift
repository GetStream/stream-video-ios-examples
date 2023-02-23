//
//  MeetingViewFactory.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 17.2.23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI
import EffectsLibrary

class MeetingViewFactory: ViewFactory {
    
    private init() {}
    
    static let shared = MeetingViewFactory()
    
    func makeCallControlsView(viewModel: CallViewModel) -> some View {
        CustomCallControls(viewModel: viewModel)
    }
    
    func makeCallView(viewModel: CallViewModel) -> some View {
        CustomCallView(viewModel: viewModel)
    }
    
    func makeVideoCallParticipantModifier(
        participant: CallParticipant,
        participantCount: Int,
        availableSize: CGSize,
        ratio: CGFloat
    ) -> some ViewModifier {
        CustomParticipantViewModifier(
            participant: participant,
            participantCount: participantCount,
            availableSize: availableSize,
            ratio: ratio
        )
    }
    
}

struct CustomCallView: View {
    
    @ObservedObject var reactionsHelper = ReactionsHelper.shared
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        CallView(viewFactory: MeetingViewFactory.shared, viewModel: viewModel)
            .overlay(
                reactionsHelper.showFireworks ? FireworksView(config: FireworksConfig(intensity: .high, lifetime: .long, initialVelocity: .fast)) : nil
            )
    }
    
}
