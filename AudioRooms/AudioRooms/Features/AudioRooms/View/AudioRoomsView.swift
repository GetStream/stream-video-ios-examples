//
//  AudioRoomsView.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import StreamVideo
import SwiftUI

struct AudioRoomsView: View {
    
    @StateObject var viewModel = AudioRoomsViewModel()
    
    @ObservedObject var appState: AppState
    
    @Injected(\.streamVideo) var streamVideo
    
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
                .sheet(item: $viewModel.selectedAudioRoom) { audioRoom in
                    AudioRoomView(audioRoom: audioRoom)
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
                                url: streamVideo.user.imageURL!,
                                size: 32
                            )
                        }
                        .padding(8)
                        .overlay(Capsule().stroke(Color.secondary, lineWidth: 1))
                    }
                    .padding()
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
