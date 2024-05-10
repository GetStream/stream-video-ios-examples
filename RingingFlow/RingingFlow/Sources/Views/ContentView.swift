//
//  ContentView.swift
//  RingingFlow
//
//  Created by Ilias Pavlidakis on 9/5/24.
//

import Intents
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct ContentView: View {

    @Injected(\.streamVideo) var streamVideo
    @Injected(\.callKitAdapter) var callKitAdapter

    @State var callId: String = ""
    @State var callType: String = .default
    @State var participantId: String = Configuration.otherUserId
    @State var userWasBusy = false
    @State var isBusyEventObservationTask: Task<Void, Never>?
    @State var presentUserWasBusy: Bool = false
    @State private var lastCall: Call?

    @ObservedObject var callViewModel: CallViewModel

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    makeFieldRow(
                        title: "Call Type",
                        prompt: "Enter a call type",
                        text: $callType,
                        label: { Image(systemName: "info") },
                        action: { }
                    )

                    makeFieldRow(
                        title: "Call Id",
                        prompt: "Enter a call id",
                        text: $callId,
                        label: { Image(systemName: "arrow.circlepath") },
                        action: { generateCallId() }
                    )

                    makeFieldRow(
                        title: "Participant Id",
                        prompt: "Enter the id of the user to call",
                        text: $participantId,
                        label: { Image(systemName: "person") },
                        action: { }
                    )
                }
            }

            VStack {
                Text("You are connected as: \(Text(streamVideo.user.name).foregroundColor(.primary).fontWeight(.medium))")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)

                Button {
                    callViewModel.startCall(
                        callType: callType,
                        callId: callId,
                        members: [
                            .init(userId: participantId),
                            .init(userId: streamVideo.user.id)
                        ],
                        ring: true
                    )
                } label: {
                    Label(
                        title: { Text("Call \(participantId)") },
                        icon: { Image(systemName: "phone") }
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(isCallButtonEnabled ? Color.blue : Color.gray.opacity(0.3))
                    .clipShape(Capsule())
                    .disabled(!isCallButtonEnabled)
                }
            }
        }
        .padding()
        .onAppear {
            generateCallId()
        }
        .modifier(
            CallModifier(
                viewFactory: CustomViewFactory.shared,
                viewModel: callViewModel
            )
        )
        .onReceive(streamVideo.state.$activeCall, perform: { activeCall in
            callViewModel.setActiveCall(activeCall)
        })
        .onCallEnded(presentationValidator: { $0?.state.createdBy?.id == streamVideo.user.id }) { call, dismiss in
            if let call {
                CallAgainView(
                    callViewModel: callViewModel,
                    call: call,
                    userWasBusy: userWasBusy,
                    dismiss: {
                        userWasBusy = false
                        presentUserWasBusy = false
                        lastCall = nil
                        dismiss()
                    }
                )
            }
        }
        .onReceive(callViewModel.$call) { call in
            if let call {
                userWasBusy = false
                lastCall = call
                isBusyEventObservationTask = Task {
                    for await event in call.subscribe(for: CustomVideoEvent.self) {
                        guard
                            event.custom[CustomEvent.isBusy.rawValue] != nil
                        else {
                            return
                        }
                        Task { @MainActor in
                            userWasBusy = true
                        }

                    }
                }
            } else if call == nil, userWasBusy {
                presentUserWasBusy = true
                isBusyEventObservationTask = nil
            }
        }
        .sheet(isPresented: $presentUserWasBusy) {
            if let lastCall {
                CallAgainView(
                    callViewModel: callViewModel,
                    call: lastCall,
                    userWasBusy: true,
                    dismiss: {
                        userWasBusy = false
                        presentUserWasBusy = false
                        self.lastCall = nil
                    }
                )
            }
        }
    }

    // MARK: - Private helpers

    private var isCallButtonEnabled: Bool {
        !callId.isEmpty && !participantId.isEmpty
    }

    private func generateCallId() {
        callId = UUID()
            .uuidString
            .replacingOccurrences(of: "-", with: "")
            .prefix(10)
            .map(String.init)
            .joined()
    }

    private func makeFieldRow(
        title: String,
        prompt: String,
        text: Binding<String>,
        @ViewBuilder label: () -> some View,
        action: @escaping () -> Void
    ) -> some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.secondary)

            HStack {
                TextField(text: text) { Text(prompt) }
                Button {
                    action()
                } label: {
                    label()
                }
            }
        }
        .foregroundColor(Color.primary)
        .padding()
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
