//
//  ParticipantView.swift
//  AudioRooms
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import SwiftUI
import StreamVideo

struct ParticipantView: View {
    var participant: CallParticipant
    
    var body: some View {
        VStack{
            ZStack {
                Circle()
                    .fill(participant.isSpeaking ? .green : .white)
                    .frame(width: 68, height: 68)
                AsyncImage(
                    url: participant.profileImageURL,
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 64, maxHeight: 64)
                            .clipShape(Circle())
                    },
                    placeholder: {
                        Image(systemName: "person.crop.circle").font(.system(size: 60))
                    }
                )
            }
            Text("\(participant.name)")
        }
    }
}
