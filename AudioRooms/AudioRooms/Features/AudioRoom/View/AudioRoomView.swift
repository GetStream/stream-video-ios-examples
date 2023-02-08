//
//  AudioRoomView.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 30.1.23.
//

import StreamVideo
import SwiftUI
import NukeUI

import SwiftUI

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
            
            ParticipantsView(participants: viewModel.hosts)

            
            if viewModel.otherUsers.count > 0 {
                Text("Listeners")
                ParticipantsView(participants: viewModel.otherUsers)
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
                }
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
