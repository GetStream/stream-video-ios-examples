//
//  CallView.swift
//  UICookbook
//
//  Created by Martin Mitrevski on 13.3.23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI
import NukeUI

struct CallView: View {
        
    @ObservedObject var viewModel: CallViewModel
    
    var participants: [CallParticipant] {
        viewModel
            .callParticipants.map(\.value)
            .sorted(using: defaultComparators)
    }
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { reader in
                    if let dominantSpeaker = participants.first {
                        VideoCallParticipantView(
                            participant: dominantSpeaker,
                            availableSize: reader.size,
                            contentMode: .scaleAspectFit,
                            customData: [:],
                            call: viewModel.call
                        )
                    }
                    
                    VStack {
                        Spacer()
                        CustomCallControlsView(viewModel: viewModel)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(32)
            .padding(.bottom)
            .padding(.horizontal)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(participants.dropFirst()) { participant in
                        BottomParticipantView(participant: participant)
                    }
                }
            }
            .padding(.all, 32)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
        }
        .background(Color.black)
    }
}

struct BottomParticipantView: View {
    
    var participant: CallParticipant
    
    var body: some View {
        UserAvatar(imageURL: participant.profileImageURL, size: 80)
            .overlay(
                !participant.hasAudio ?
                    BottomRightView {
                        MuteIndicatorView()
                    }
                : nil
            )
    }
    
}

struct MuteIndicatorView: View {
    
    var body: some View {
        Image(systemName: "mic.slash.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 14)
            .padding(.all, 12)
            .foregroundColor(.gray)
            .background(Color.black)
            .clipShape(Circle())
            .offset(x: 4, y: 8)
    }
    
}
