//
//  AudioRoomsView.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import StreamVideo
import SwiftUI
import NukeUI

struct AudioRoomsView: View {
    
    @Injected(\.streamVideo) var streamVideo
    
    @StateObject var viewModel = AudioRoomsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.audioRooms) { audioRoom in
                        Button {
                            viewModel.selectedAudioRoom = audioRoom
                        } label: {
                            AudioRoomCell(audioRoom: audioRoom)
                        }
                    }
                }
                .sheet(item: $viewModel.selectedAudioRoom, content: { audioRoom in
                    AudioRoomView(audioRoom: audioRoom)
                })
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.logoutAlertShown = true
                    } label: {
                        LazyImage(url: streamVideo.user.imageURL)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            })
            .navigationTitle("Audio Rooms")
            .alert(isPresented: $viewModel.logoutAlertShown) {
                Alert(
                    title: Text("Sign out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign out")) {
                        withAnimation {
                            if let userToken = UnsecureUserRepository.shared.currentVoipPushToken() {
                                let controller = streamVideo.makeVoipNotificationsController()
                                controller.removeDevice(with: userToken)
                            }
                            UnsecureUserRepository.shared.removeCurrentUser()
                            Task {
                                await streamVideo.disconnect()
                                AppState.shared.streamVideo = nil
                                AppState.shared.userState = .notLoggedIn
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct AudioRoomCell: View {
    
    let audioRoom: AudioRoom
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(audioRoom.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(audioRoom.subtitle)
                    .multilineTextAlignment(.leading)
                    .font(.caption)
                HStack(alignment: .top, spacing: 16) {
                    if audioRoom.hosts.count > 1 {
                        ZStack(alignment: .topLeading) {
                            LazyImage(url: audioRoom.hosts[0].imageURL)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            LazyImage(url: audioRoom.hosts[1].imageURL)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .offset(x: 20, y: 20)
                        }
                        .frame(height: 70)
                    }
                    VStack(alignment: .leading) {
                        ForEach(audioRoom.hosts) { host in
                            Text(host.name)
                                .font(.headline)
                        }
                    }
                    .padding()
                }
            }
            .padding()
            
            Spacer()
        }
        .background(Color("CardBackground"))
        .foregroundColor(.primary)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
}
