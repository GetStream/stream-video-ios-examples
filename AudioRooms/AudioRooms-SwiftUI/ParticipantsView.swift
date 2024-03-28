//
//  ParticipantsView.swift
//  AudioRooms
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import SwiftUI
import StreamVideo

struct ParticipantsView: View {
    var participants: [CallParticipant]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
            ForEach(participants) {
                ParticipantView(participant: $0)
            }
        }
    }
}
