//
//  PermissionRequestsView.swift
//  AudioRooms
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import SwiftUI
import StreamVideo

struct PermissionRequestsView: View {
    var call: Call
    @ObservedObject var state: CallState

    var body: some View {
        if let request = state.permissionRequests.first {
            HStack {
                Text("\(request.user.name) requested to \(request.permission)")
                Button {
                   Task {
                       try await call.grant(request: request)
                   }
                } label: {
                    Label("", systemImage: "hand.thumbsup.circle").tint(.green)
                }
                Button(action: request.reject) {
                    Label("", systemImage: "hand.thumbsdown.circle.fill").tint(.red)
                }
            }
        }
    }
}
