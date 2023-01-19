//
//  PreJoiningView.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 18.1.23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI
import NukeUI

struct PreJoiningView: View {
    
    @Injected(\.images) var images
    @Injected(\.streamVideo) var streamVideo
    
    @ObservedObject var callViewModel: CallViewModel
    @StateObject var viewModel = PreJoiningViewModel()
    @Binding var meeting: Meeting?
    
    private let iconSize: CGFloat = 50
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                VStack {
                    Spacer()
                    Text("Before Joining")
                        .font(.title)
                        .bold()
                    
                    Text("Setup your audio and video")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    if let image = viewModel.viewfinderImage, callViewModel.callSettings.videoOn {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: reader.size.width - 32, height:  reader.size.height / 2)
                            .cornerRadius(16)
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color("callInfoBackground"))
                                .frame(width: reader.size.width - 32, height:  reader.size.height / 2)
                                .cornerRadius(16)

                            LazyImage(url: streamVideo.user.imageURL)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        }
                        .opacity(callViewModel.callSettings.videoOn ? 0 : 1)
                        .frame(width: reader.size.width - 32, height:  reader.size.height / 2)
                    }
                    
                    HStack(spacing: 32) {
                        Button {
                            let callSettings = callViewModel.callSettings
                            callViewModel.callSettings = CallSettings(
                                audioOn: !callSettings.audioOn,
                                videoOn: callSettings.videoOn,
                                speakerOn: callSettings.speakerOn
                            )
                        } label: {
                            CallIconView(
                                icon: (callViewModel.callSettings.audioOn ? images.micTurnOn : images.micTurnOff),
                                size: iconSize,
                                iconStyle: (callViewModel.callSettings.audioOn ? .primary : .transparent)
                            )
                        }

                        Button {
                            let callSettings = callViewModel.callSettings
                            callViewModel.callSettings = CallSettings(
                                audioOn: callSettings.audioOn,
                                videoOn: !callSettings.videoOn,
                                speakerOn: callSettings.speakerOn
                            )
                        } label: {
                            CallIconView(
                                icon: (callViewModel.callSettings.videoOn ? images.videoTurnOn : images.videoTurnOff),
                                size: iconSize,
                                iconStyle: (callViewModel.callSettings.videoOn ? .primary : .transparent)
                            )
                        }
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Image("stream")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("customBlue"))
                                .clipShape(Circle())
                            
                            Text("You are about to join a test call at Stream. \(otherParticipantsCount) more people are in the call.")
                                .font(.headline)
                        }
                        
                        Button {
                            if let meeting {
                                callViewModel.startCall(callId: meeting.id, participants: meeting.participants)
                            }
                            self.meeting = nil
                        } label: {
                            Text("Join Call")
                                .bold()
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color("customBlue"))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color("callInfoBackground"))
                    .cornerRadius(16)
                    
                }
                .padding()
                
                TopRightView {
                    Button {
                        meeting = nil
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("prejoinBackground").edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            Task {
                await viewModel.camera.start()
                viewModel.camera.switchCaptureDevice()
            }
        }
    }
    
    private var otherParticipantsCount: Int {
        if let meeting {
            return meeting.participants.count - 1
        }
        return 1
    }
    
}
