//
//  CallAgainView.swift
//  RingingFlow
//
//  Created by Ilias Pavlidakis on 9/5/24.
//

import Foundation
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct CallAgainView: View {

    @Injected(\.streamVideo) var streamVideo

    var callViewModel: CallViewModel
    var call: Call
    var userWasBusy: Bool
    var dismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                messageView
                    .frame(maxHeight: .infinity, alignment: .top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical)

                Button {
                    dismiss()
                    callViewModel.startCall(
                        callType: call.callType,
                        callId: UUID().uuidString.replacingOccurrences(of: "-", with: "").map(String.init).joined(),
                        members: call.state.members,
                        ring: true
                    )
                } label: {
                    Label(
                        title: { Text("Call \(otherParticipants.map(\.id).joined(separator: ",")) again") },
                        icon: { Image(systemName: "phone") }
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
                }

                Button {
                    dismiss()
                } label: {
                    Label(
                        title: { Text("Cancel") },
                        icon: { EmptyView() }
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.secondary)
                    .clipShape(Capsule())
                }
            }
            .padding()
            .navigationTitle("Call ended")
        }
    }

    @ViewBuilder
    @MainActor
    private var messageView: some View {
        if userWasBusy {
            Text("\(otherParticipants.map(\.id).joined(separator: ",")) were busy. Please try calling again later.")
        } else {
            Text("It seems your call with \(otherParticipants.map(\.id).joined(separator: ",")) was ended. If you would like you can call them again.")
        }
    }

    @MainActor
    private var otherParticipants: [User] {
        call
            .state
            .members
            .filter { $0.user.id != streamVideo.user.id }
            .map(\.user)
    }
}
