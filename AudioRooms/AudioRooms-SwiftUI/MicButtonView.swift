//
//  MicButtonView.swift
//  AudioRooms
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import SwiftUI
import StreamVideo

struct MicButtonView: View {
    @ObservedObject var microphone: MicrophoneManager

    var body: some View {
        Button {
           Task {
               try await microphone.toggle()
           }
        } label: {
            Image(systemName: microphone.status == .enabled ? "mic.circle" : "mic.slash.circle")
                .foregroundColor(microphone.status == .enabled ? .red : .primary)
                .font(.title)
        }
    }
}
