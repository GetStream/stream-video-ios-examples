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
                Spacer()
                Button {
                    viewModel.leaveCall()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Leave quitely")
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
            viewModel.loading ? ProgressView() : nil
        )
        .padding()
    }
}

struct AudioRoomView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRoomView(audioRoom: .preview)
    }
}