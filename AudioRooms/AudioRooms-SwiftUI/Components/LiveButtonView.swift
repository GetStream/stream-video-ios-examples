//
//  LiveButtonView.swift
//  AudioRooms
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import SwiftUI
import StreamVideo

struct LiveButtonView: View {
    var call: Call
    @ObservedObject var state: CallState

    var body: some View {
        if state.backstage {
            Button {
                Task {
                    try await call.goLive()
                }
            } label: {
                Text("Go Live")
            }
            .buttonStyle(.borderedProminent).tint(.green)
        } else {
            Button {
                Task {
                    try await call.stopLive()
                }
            } label: {
                Text("Stop live")
            }
            .buttonStyle(.borderedProminent).tint(.red)
        }
    }
}
