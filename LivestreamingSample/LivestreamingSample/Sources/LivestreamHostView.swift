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
    
    @MainActor
    private var participants: [CallParticipant] {
        return call.state.participants.sorted { (first, second) -> Bool in
            for comparator in defaultComparators {
                let result = comparator(first, second)
                if result != .orderedSame {
                    return result == .orderedAscending
                }
            }
            return false
        }
        //return call.state.participants.sorted(using: defaultComparators)
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
                        availableFrame: CGRect(origin: .zero, size: reader.size),
                        contentMode: .scaleAspectFit,
                        edgesIgnoringSafeArea: .bottom,
                        customData: [:],
                        call: call
                    )
                } else {
                    Color(UIColor.secondarySystemBackground)
                }
            }
            .padding()
            
            ZStack {
                HStack {
                    if isBroadcasting {
                        Button {
                            Task {
                                isLoading = true
                                try await call.stopHLS()
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
                                try await call.startHLS()
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
        .task {
            for await videoEvent in call.subscribe() {
                switch videoEvent {
                case .typeCallHLSBroadcastingStartedEvent:
                    self.isBroadcasting = true
                    self.isLoading = false
                case .typeCallHLSBroadcastingStoppedEvent:
                    self.isBroadcasting = false
                    self.isLoading = false
                default:
                    break
                }
            }
        }
    }
}
