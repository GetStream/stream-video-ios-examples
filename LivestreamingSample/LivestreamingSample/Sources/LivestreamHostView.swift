//
//  LivestreamHostView.swift
//  LivestreamingSample
//
//  Created by Martin Mitrevski on 8.5.23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct LivestreamHostView: View {
    
    @Injected(\.streamVideo) var streamVideo
    
    var call: Call

    @State var isBroadcasting = false
    @State var isLoading = false
    
    var onLeaveCall: () -> ()
    
    private var participants: [CallParticipant] {
        return call.state.participants.map(\.value).sorted(using: defaultComparators)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Live")
                    .bold()
                    .padding(.all, 4)
                    .padding(.horizontal, 2)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .opacity(isBroadcasting ? 1 : 0)
            }
            
            GeometryReader { reader in
                if let first = participants.first {
                    VideoCallParticipantView(
                        participant: first,
                        availableSize: reader.size,
                        contentMode: .scaleAspectFit,
                        edgesIgnoringSafeArea: .bottom,
                        customData: [:]
                    ) { participant, view in
                            view.handleViewRendering(for: participant) { size, participant in }
                        }
                } else {
                    Color(UIColor.secondarySystemBackground)
                }
            }
            .padding()
            
            ZStack {
                HStack {
                    if isBroadcasting && !isLoading {
                        Button {
                            Task {
                                isLoading = true
                                try await call.stopBroadcasting()
                            }
                        } label: {
                            Text("Stop stream")
                                .foregroundColor(.white)
                                .padding(.all, 8)
                                .background(Color.black)
                                .cornerRadius(8)
                        }
                    } else {
                        Button {
                            Task {
                                isLoading = true
                                try await call.startBroadcasting()
                            }
                        } label: {
                            Text("Start stream")
                                .foregroundColor(.white)
                                .padding(.all, 8)
                                .background(Color.black)
                                .cornerRadius(8)
                        }
                    }
                    
                    Button {
                        onLeaveCall()
                    } label: {
                        Text("Leave call")
                            .foregroundColor(.white)
                            .padding(.all, 8)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
                .opacity(isLoading ? 0 : 1)
                
                ProgressView()
                    .opacity(isLoading ? 1 : 0)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
        .onReceive(call.state.$egress, perform: { newValue in
            isBroadcasting = newValue?.broadcasting == true
            if isBroadcasting {
                isLoading = false
            }
        })
    }
}
