//
//  LivestreamHomeView.swift
//  LivestreamingSample
//
//  Created by Martin Mitrevski on 8.5.23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct LivestreamHomeView: View {
    
    @Injected(\.streamVideo) var streamVideo
    
    @StateObject var viewModel = LivestreamHomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    VStack {
                        TextField("Insert livestream id", text: $viewModel.callId)
                            .frame(maxWidth: .infinity)
                        Button {
                            resignFirstResponder()
                            viewModel.createLivestream()
                        } label: {
                            Text("Create and join")
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding()
                    
                    VStack {
                        TextField("Insert call id to watch", text: $viewModel.watchedCallId)
                            .frame(maxWidth: .infinity)
                        Button {
                            resignFirstResponder()
                            viewModel.watchCall()
                        } label: {
                            Text("Watch")
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding()
                    
                    if let watchedCall = viewModel.watchedCall {
                        VStack(alignment: .leading) {
                            Text("Watching stream")
                                .bold()
                            HStack {
                                Text("\(watchedCall.cId)")
                                Spacer()
                                if let url = viewModel.hlsURL {
                                    NavigationLink {
                                        LazyView(
                                            PlayerView(url: url)
                                        )
                                    } label: {
                                        Text("Join livestream")
                                            .foregroundColor(.white)
                                            .padding(.all, 8)
                                    }
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                
                if viewModel.loading {
                    ProgressView()
                }
                
                if let call = viewModel.call {
                    LivestreamHostView(call: call) {
                        call.leave()
                        Task {
                            try? await call.stopBroadcasting()
                        }
                        viewModel.call = nil
                    }
                }
            }
            .navigationTitle("Livestreaming sample")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.logoutAlertShown = true
                    } label: {
                        UserAvatar(imageURL: streamVideo.user.imageURL, size: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $viewModel.logoutAlertShown) {
                Alert(
                    title: Text("Sign out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign out")) {
                        withAnimation {
                            AppState.shared.logout()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct LazyView<Content: View>: View {
    private let build: () -> Content

    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    public var body: Content {
        build()
    }
}
