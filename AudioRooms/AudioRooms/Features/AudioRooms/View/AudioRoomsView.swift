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
    @State private var audioRoomType: AudioRoom.AudioRoomType = .live

    private var datasource: [AudioRoom] {
        switch audioRoomType {
        case .live:
            return viewModel.liveAudioRooms
        case .upcoming:
            return viewModel.upcomingAudioRooms
        case .ended:
            return viewModel.endedAudioRooms
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    Picker("", selection: $audioRoomType) {
                        ForEach(AudioRoom.AudioRoomType.allCases, id: \.self) { roomType in
                            Text(roomType.description).tag(roomType)
                        }
                    }
                    .pickerStyle(.segmented)

                    ScrollView {
                        LazyVStack {
                            ForEach(datasource) { audioRoom in
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
                        HStack(spacing: 8) {
                            Text("Logout")
                                .foregroundColor(.primary)
                            
                            ImageFromUrl(
                                url: streamVideo.user.imageURL,
                                size: 26
                            )
                        }
                        .padding([.leading, .trailing], 12)
                        .padding([.top, .bottom], 6)
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
        .onAppear {
            viewModel.loadRooms()
        }
    }
}

struct AudioRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        InjectedValues[\.streamVideo] = StreamVideo(
            apiKey: UUID().uuidString,
            user: .anonymous,
            token: .init(stringLiteral: UUID().uuidString)
        )
        return AudioRoomsView(appState: AppState())
    }
}
