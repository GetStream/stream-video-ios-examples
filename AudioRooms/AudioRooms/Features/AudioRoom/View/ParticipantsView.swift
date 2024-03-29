//
//  ParticipantsView.swift
//  AudioRooms
//
//  Created by Stefan Blos on 08.02.23.
//

import SwiftUI
import StreamVideo

struct ParticipantsView: View {
    
    var participants: [CallParticipant]
    var onLongPress: (CallParticipant) -> ()
    
    var body: some View {
        HStack {
            ForEach(participants) { participant in
                VStack {
                    ZStack(alignment: .bottomTrailing) {
                        ImageFromUrl(
                            url: participant.profileImageURL,
                            size: 64
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    Color.blue,
                                    lineWidth: participant.isSpeaking ? 1 : 0
                                )
                        )
                        
                        if !participant.hasAudio {
                            IconView(imageName: "mic.slash")
                                .frame(width: 12, height: 12)
                        }
                    }
                    .onLongPressGesture {
                        onLongPress(participant)
                    }
                    
                    Text(participant.name)
                        .lineLimit(1)
                        .font(.caption)
                        .frame(maxWidth: 64)
                }
            }
        }
    }
}
