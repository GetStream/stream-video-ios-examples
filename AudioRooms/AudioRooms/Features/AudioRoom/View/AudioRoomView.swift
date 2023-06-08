//
//  AudioRoomView.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 30.1.23.
//

import SwiftUI
import StreamVideo

struct AudioRoomView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: AudioRoomViewModel

    private let audioRoom: AudioRoom

    init(audioRoom: AudioRoom) {
       self.audioRoom = audioRoom
       _viewModel = StateObject(
          wrappedValue: AudioRoomViewModel(audioRoom: audioRoom)
       )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if viewModel.showGoLiveButton {
                    Button {
                        viewModel.goLive()
                    } label: {
                        Text("Go live")
                    }
                }
                if viewModel.showStopLiveButton {
                    Button {
                        viewModel.stopLive()
                    } label: {
                        Text("Stop live")
                    }
                }
                Spacer()

                if viewModel.showEndCallButton {
                    Menu {
                        VStack {
                            Button {
                                viewModel.leaveCall()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Leave quitely")
                            }

                            if viewModel.showEndCallButton {
                                Button {
                                    viewModel.endCall()
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Text("End")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                } else {
                    Button {
                        viewModel.leaveCall()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Leave quitely")
                    }
                }
            }
            .padding(.bottom, 16)
            
            Text(audioRoom.title)
                .font(.headline)
            
            Text(audioRoom.subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ParticipantsView(participants: viewModel.hosts) { participant in
                viewModel.revokingParticipant = participant
            }
            .alert(isPresented: $viewModel.revokePermissionPopupShown) {
                Alert(
                    title: Text("Revoke permissions"),
                    message: Text("Do you want to revoke the permissions of \(viewModel.revokingParticipant?.name ?? "unknown")?"),
                    primaryButton: .default(Text("Revoke")) {
                        viewModel.revokePermissions()
                    },
                    secondaryButton: .cancel()
                )
            }
            
            if viewModel.otherUsers.count > 0 {
                Text("Listeners")
                ParticipantsView(participants: viewModel.otherUsers) { _ in }
            }
        
            Spacer()
            
            HStack {
                Spacer()
                if viewModel.hasPermissionsToSpeak {
                    Button {
                        viewModel.changeMuteState()
                    } label: {
                        IconView(imageName: viewModel.isUserMuted ? "mic.slash" : "mic")
                    }
                } else if viewModel.canAskForAudioPermission() {
                    Button {
                        viewModel.raiseHand()
                    } label: {
                        IconView(imageName: "hand.raised")
                    }
                }
            }
            .alert(isPresented: $viewModel.permissionPopupShown) {
                Alert(
                    title: Text("Permission request"),
                    message: Text("\(viewModel.permissionRequest?.user.name ?? "Someone") raised their hand to speak."),
                    primaryButton: .default(Text("Allow")) {
                        viewModel.grantUserPermissions()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .opacity(viewModel.loading ? 0 : 1)
        .overlay(
            ZStack {
                if viewModel.loading {
                    if viewModel.callEnded {
                        Text("Call ended")
                    } else {
                        ProgressView()
                    }
                }
            }
        )
        .padding()
        .onDisappear {
            viewModel.leaveCall()
        }
    }
}

struct AudioRoomView_Previews: PreviewProvider {
    static var previews: some View {
        InjectedValues[\.streamVideo] = StreamVideo(
            apiKey: UUID().uuidString,
            user: .anonymous,
            token: .anonymous
        )
        return AudioRoomView(audioRoom: .preview)
    }
}
