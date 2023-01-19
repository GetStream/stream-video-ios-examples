//
//  ContentView.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 17.1.23.
//

import StreamVideo
import StreamVideoSwiftUI
import SwiftUI

struct ContentView: View {
    @StateObject var callViewModel = CallViewModel()
    @State var callId = ""

    var body: some View {
        VStack {
            TextField("Insert a call id", text: $callId)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button {
                resignFirstResponder()
                callViewModel.startCall(
                    callId: callId,
                    participants: [/* Your list of participants goes here. */]
                )
            } label: {
                Text("Start a call")
            }
        }
        .padding()
        .modifier(CallModifier(viewModel: callViewModel))
    }
}
