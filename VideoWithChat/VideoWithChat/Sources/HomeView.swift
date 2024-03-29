//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Intents
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: CallViewModel
    
    @Injected(\.streamVideo) var streamVideo
    
    private let imageSize: CGFloat = 32
        
    @State private var callId = ""
    
    @State private var callAction = CallAction.startCall
    
    var participants: [User] {
        var participants = User.builtInUsers
        participants.removeAll { userInfo in
            userInfo.id == streamVideo.user.id
        }
        return participants
    }
    
    @State var selectedParticipants = [User]()
    @State var incomingCallInfo: IncomingCall?
    @State var logoutAlertShown = false
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button {
                        logoutAlertShown = true
                    } label: {
                        StreamLazyImage(imageURL: streamVideo.user.imageURL)
                            .frame(width: imageSize, height: imageSize)
                            .clipShape(Circle())
                    }
                    .padding()

                    Spacer()
                }
                Text("Call details")
                    .font(.title)
                    .padding()
            }
            
            Picker("Call action", selection: $callAction) {
                Text(CallAction.startCall.rawValue).tag(CallAction.startCall)
                Text(CallAction.joinCall.rawValue).tag(CallAction.joinCall)
            }
            .pickerStyle(.segmented)
            
            TextField("Insert a call id", text: $callId)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            if callAction == .startCall {
                startCallView
                    .transition(.opacity)
            } else {
                Button {
                    viewModel.joinCall(callType: .default, callId: callId)
                } label: {
                    Text("Join a call")
                        .padding()
                }
                .foregroundColor(Color.white)
                .background(makeCallEnabled ? Color.gray : Color.blue)
                .disabled(makeCallEnabled)
                .cornerRadius(16)
                .transition(.opacity)
            }

            Spacer()
        }
        .alert(isPresented: $logoutAlertShown) {
            Alert(
                title: Text("Sign out"),
                message: Text("Are you sure you want to sign out?"),
                primaryButton: .destructive(Text("Sign out")) {
                    withAnimation {
                        if let userToken = UnsecureUserRepository.shared.currentVoipPushToken() {
                            Task {
                                try await streamVideo.deleteDevice(id: userToken)
                            }
                        }
                        UnsecureUserRepository.shared.removeCurrentUser()
                        Task {
                            await AppState.shared.streamWrapper?.logout()
                            AppState.shared.userState = .notLoggedIn
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var makeCallEnabled: Bool {
        callId.isEmpty || participants.isEmpty
    }
    
    var startCallView: some View {
        Group {
            HStack {
                Text("Select participants")
                    .font(.title2)
                Spacer()
            }
            .padding(.horizontal)
            
            List(participants) { participant in
                Button {
                    if selectedParticipants.contains(participant) {
                        selectedParticipants.removeAll { user in
                            user.id == participant.id
                        }
                    } else {
                        selectedParticipants.append(participant)
                    }
                } label: {
                    HStack {
                        StreamLazyImage(imageURL: participant.imageURL)
                            .frame(width: imageSize, height: imageSize)
                            .clipShape(Circle())
                        Text(participant.name)
                        Spacer()
                        if selectedParticipants.contains(participant) {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding(.all, 8)
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height / 4)
            .listStyle(PlainListStyle())
                        
            Button {
                resignFirstResponder()
                viewModel.startCall(
                    callType: .default,
                    callId: callId,
                    members: selectedParticipants.map { MemberRequest(custom: $0.customData, role: $0.role, userId: $0.id) }
                )
            } label: {
                Text("Start a call")
                    .padding()
            }
            .foregroundColor(Color.white)
            .background(makeCallEnabled ? Color.gray : Color.blue)
            .disabled(makeCallEnabled)
            .cornerRadius(16)
        }
    }
}

enum CallAction: String {
    case startCall = "Start a call"
    case joinCall = "Join a call"
}
