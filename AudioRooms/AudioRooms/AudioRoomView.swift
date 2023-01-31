//
//  AudioRoomView.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 30.1.23.
//

import StreamVideo
import SwiftUI
import NukeUI

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
                } else {
                    Button {
                        viewModel.raiseHand()
                    } label: {
                        IconView(imageName: "hand.raised")
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

struct IconView: View {
    
    let imageName: String
    
    var body: some View {
        Image(systemName: imageName)
            .padding(.all, 8)
            .background(Color("CardBackground"))
            .foregroundColor(.primary)
            .clipShape(Circle())
    }
    
}

struct ParticipantsView: View {
    
    var participants: [CallParticipant]
    
    var body: some View {
        HStack {
            ForEach(participants) { participant in
                VStack {
                    LazyImage(url: participant.profileImageURL)
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: participant.isSpeaking ? 1 : 0)
                        )
                        .overlay(
                            !participant.hasAudio ?
                                BottomRightView {
                                    IconView(imageName: "mic.slash")
                                        .offset(x: 8, y: 12)
                                }
                            : nil
                        )
                    Text(participant.name)
                }
            }
        }
    }
}

public struct BottomRightView<Content: View>: View {
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
        
    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                content()
            }
        }
    }
}
