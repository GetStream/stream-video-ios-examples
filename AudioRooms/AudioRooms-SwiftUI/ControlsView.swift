//
//  ControlsView.swift
//  AudioRooms
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import SwiftUI
import StreamVideo

struct ControlsView: View {
    var call: Call
    @ObservedObject var state: CallState

    var body: some View {
        HStack {
            MicButtonView(microphone: call.microphone)
            LiveButtonView(call: call, state: state)
        }
    }
}
