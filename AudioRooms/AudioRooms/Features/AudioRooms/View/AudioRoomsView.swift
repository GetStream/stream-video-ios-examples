//
//  AudioRoomsView.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import SwiftUI
import StreamVideo

struct AudioRoomsView: View {
    
    @StateObject var viewModel = AudioRoomsViewModel()
    
    @ObservedObject var appState: AppState
    
    @Injected(\.streamVideo) var streamVideo
    
    @State private var showCreateRoom = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
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
                    .sheet(item: $viewModel.selectedAudioRoom) { audioRoom in
                        AudioRoomView(audioRoom: audioRoom)
                    }
                }
                
                if let _ = appState.currentUser {
                    Button {
                        showCreateRoom = true
                    } label: {
                        Label("Create", systemImage: "plus")
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(in: Capsule())
                    .overlay(Capsule().stroke(Color.secondary, lineWidth: 1))
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 4)
                    .padding(20)
                }
            }
            .navigationTitle("Audio Rooms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appState.logout()
                    } label: {
                        HStack {
                            Text("Logout")
                                .foregroundColor(.primary)
                            
                            ImageFromUrl(
                                url: streamVideo.user.imageURL,
                                size: 32
                            )
                        }
                        .padding(8)
                        .overlay(Capsule().stroke(Color.secondary, lineWidth: 1))
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showCreateRoom) {
                if let user = appState.currentUser {
                    CreateRoomForm(user: user)
                } else {
                    Text("No user found.")
                }
            }
        }
    }
}

struct AudioRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRoomsView(appState: AppState())
    }
}
