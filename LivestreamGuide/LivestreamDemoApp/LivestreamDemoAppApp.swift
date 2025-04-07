//
//  LivestreamDemoAppApp.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 3.4.25.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

@main
struct LivestreamDemoAppApp: App {
    
    @State var streamVideo: StreamVideo?
    @State var livestreamHostShown = false
    @State var livestreamViewerShown = false
    @State var livestreamPlayerViewerShown = false
    
    init() {
        LogConfig.level = .debug
    }
        
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                VStack(spacing: 32) {
                    Button {
                        let host = UserCredentials.host
                        streamVideo = StreamVideo(
                            apiKey: "mmhfdzb5evj2",
                            user: User(id: host.id, name: host.id),
                            token: UserToken(rawValue: host.token)
                        )
                        livestreamHostShown = true
                    } label: {
                        Text("Join as host")
                    }

                    Button {
                        let viewer = UserCredentials.viewer
                        streamVideo = StreamVideo(
                            apiKey: "mmhfdzb5evj2",
                            user: User(id: viewer.id, name: viewer.id),
                            token: UserToken(rawValue: viewer.token)
                        )
                        livestreamViewerShown = true

                    } label: {
                        Text("Join as viewer")
                    }
                    
                    Button {
                        let viewer = UserCredentials.viewer
                        streamVideo = StreamVideo(
                            apiKey: "mmhfdzb5evj2",
                            user: User(id: viewer.id, name: viewer.id),
                            token: UserToken(rawValue: viewer.token)
                        )
                        livestreamPlayerViewerShown = true

                    } label: {
                        Text("Join as viewer (livestream player)")
                    }
                }
                .navigationDestination(isPresented: $livestreamHostShown) {
                    LivestreamView(streamVideo: streamVideo, userCredentials: .host)
                }
                .navigationDestination(isPresented: $livestreamViewerShown) {
                    LivestreamView(streamVideo: streamVideo, userCredentials: .viewer)
                }
                .navigationDestination(isPresented: $livestreamPlayerViewerShown) {
                    if livestreamPlayerViewerShown {
                        LivestreamPlayer(type: "livestream", id: callId)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}

struct UserCredentials: Identifiable {
    let id: String
    let token: String
    let isHost: Bool
}

extension UserCredentials {
    static let host = UserCredentials(
        id: "Darth_Vader",
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0RhcnRoX1ZhZGVyIiwidXNlcl9pZCI6IkRhcnRoX1ZhZGVyIiwidmFsaWRpdHlfaW5fc2Vjb25kcyI6NjA0ODAwLCJpYXQiOjE3NDM2OTE1ODYsImV4cCI6MTc0NDI5NjM4Nn0.SNL1p8DCH8rHtQ9FosrwxVkujV_yp8onHHnIkZ1TEOI",
        isHost: true
    )
    static let viewer = UserCredentials(
        id: "martin",
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibWFydGluIn0.HWoRAylUSkUXgPXyyyjFOyhZv9Rh8sTY7nXkovlnteg",
        isHost: false
    )
}

let callId = "Tk8abhUdsV325675"

struct LivestreamView: View {
    
    @Environment(\.dismiss) var dismiss

    let streamVideo: StreamVideo?
    @State var call: Call?
    @State var joining = false
    @State var recordings: [CallRecording]?
    @State var errorShown = false

    @StateObject var state: CallState

    let formatter = DateComponentsFormatter()
    let userCredentials: UserCredentials

    init(streamVideo: StreamVideo?, userCredentials: UserCredentials) {
        formatter.unitsStyle = .full
        
        self.userCredentials = userCredentials
        self.streamVideo = streamVideo
        
        let call = streamVideo?.call(callType: "livestream", callId: callId)
        self.call = call
        _state = StateObject(wrappedValue: call!.state)
    }
    
    private func joinCall(userCredentials: UserCredentials) {
        Task {
            joining = true
            do {
                if userCredentials.isHost {
                    try await call?.create(
                        members: [.init(role: "host", userId: userCredentials.id)],
                        startsAt: Date().addingTimeInterval(120),
                        backstage: .init(enabled: true, joinAheadTimeSeconds: 120)
                    )
                    try await call?.join()
                } else {
                    try await call?.join()
                }
                joining = false
            } catch {
                joining = false
            }
        }
    }

    var duration: String? {
        guard state.duration > 0  else { return nil }
        return formatter.string(from: state.duration)
    }

    var body: some View {
        VStack {
            if joining {
                ProgressView("Joining...")
            } else if state.endedAt != nil {
                Text("Call ended")
                    .onAppear {
                        if recordings == nil {
                            Task {
                                do {
                                    recordings = try await call?.listRecordings()
                                } catch {
                                    print("Error fetching recordings: \(error)")
                                    recordings = []
                                }
                            }
                        }
                    }
                
                if let recordings, recordings.count > 0 {
                    Text("Watch recordings:")
                    ForEach(recordings, id: \.self) { recording in
                        Button {
                            if let url = URL(string: recording.url), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text(recording.url)
                        }
                    }
                }
            } else if state.backstage {
                if let startedAt = state.startsAt {
                    Text("Livestream starting at \(startedAt.formatted())")
                } else {
                    Text("Livestream starting soon")
                }
                if let session = state.session {
                    let waitingCount = session.participants.filter({ $0.role != "host" }).count
                    if waitingCount > 0 {
                        Text("\(waitingCount) participants waiting")
                            .font(.headline)
                            .padding(.horizontal)
                    }
                }
            } else {
                HStack {
                    if let duration {
                        Text("Live for \(duration)")
                            .font(.headline)
                            .padding(.horizontal)
                    }

                    Spacer()

                    Text("Live \(state.participantCount)")
                        .bold()
                        .padding(.all, 4)
                        .padding(.horizontal, 2)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .opacity(state.backstage ? 0 : 1)
                        .padding(.horizontal)
                }

                GeometryReader { reader in
                    if let first = state.participants.first(where: { hostIds.contains($0.userId) }) {
                        VideoRendererView(id: first.id, size: reader.size) { renderer in
                            renderer.handleViewRendering(for: first) { size, participant in }
                        }
                    } else {
                        Color(UIColor.secondarySystemBackground)
                    }
                }
                .padding()
            }
            
            if isHost, let call {
                HostControls(call: call, backstage: state.backstage)
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            joinCall(userCredentials: userCredentials)
        }
        .onChange(of: state.backstage) { oldValue, newValue in
            if state.localParticipant == nil { return }
            if !oldValue && newValue && !isHost {
                call?.leave()
                call = nil
                dismiss()
            }
        }
        .onChange(of: state.reconnectionStatus) { oldValue, newValue in
            if oldValue == .reconnecting && newValue == .disconnected {
                errorShown = true
            }
        }
        .alert("You were disconnected from the call", isPresented: $errorShown, actions: {
            // add a custom error handling behaviour
        })
    }
    
    var hostIds: [String] {
        state.members.filter { $0.role == "host" }.map(\.id)
    }
    
    var isHost: Bool {
        state.localParticipant?.roles.contains("host") == true
    }
}

struct HostControls: View {
    var call: Call
    var backstage: Bool
    
    var body: some View {
        ZStack {
            if backstage {
                Button {
                    Task {
                        try await call.goLive()
                    }
                } label: {
                    Text("Go Live")
                }
            } else {
                Button {
                    Task {
                        try await call.stopLive()
                    }
                } label: {
                    Text("Stop Livestream")
                }
            }
        }
        .padding()
    }
}
