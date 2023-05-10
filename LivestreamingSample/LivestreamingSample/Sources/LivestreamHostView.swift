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
    
    @ObservedObject var call: Call
    
    @State var loading = false
    
    var onLeaveCall: () -> ()
    
    private var participants: [CallParticipant] {
        return call.participants.map(\.value).sorted(using: defaultComparators)
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
                    .opacity(call.state?.broadcasting == true ? 1 : 0)
            }
            
            GeometryReader { reader in
                if let first = participants.first {
                    VideoCallParticipantView(
                        participant: first,
                        availableSize: reader.size,
                        contentMode: .scaleAspectFit,
                        edgesIgnoringSafeArea: .bottom
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
                    if call.state?.broadcasting == true {
                        Button {
                            Task {
                                loading = true
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
                                loading = true
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
                .opacity(loading ? 0 : 1)
                
                ProgressView()
                    .opacity(loading ? 1 : 0)
            }
            .padding()
        }
        .onChange(of: call.state?.broadcasting, perform: { state in
            loading = false
        })
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            call.startCapturingLocalVideo()
        }
        
    }
}
