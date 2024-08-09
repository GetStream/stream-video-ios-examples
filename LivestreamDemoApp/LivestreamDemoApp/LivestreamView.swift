//
//  LivestreamGuestView.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 6.8.24.
//

import class StreamChat.ChatClient
import StreamVideo
import StreamVideoSwiftUI
import SwiftUI

struct LivestreamView: View {
    @State var call: Call
    
    @StateObject var state: CallState
    
    @State var pinnedProductShown = false
    @State var productsViewShown = false
    @State var vouchersShown = false
    
    @Environment(\.presentationMode) var presentationMode

    let formatter = DateComponentsFormatter()
    
    private let chatClient: ChatClient
    private let pinnedProduct: Product
    private let isHost: Bool

    init(callId: String, pinnedProduct: Product, isHost: Bool) {
        let call = InjectedValues[\.streamVideo].call(callType: "livestream", callId: callId)
        self.call = call
        self.isHost = isHost
        _state = StateObject(wrappedValue: call.state)
        self.chatClient = AppState.shared.chatClient!
        self.pinnedProduct = pinnedProduct
        formatter.unitsStyle = .full
    }

    var duration: String? {
        guard call.state.duration > 0  else { return nil }
        return formatter.string(from: call.state.duration)
    }

    var body: some View {
        VStack(spacing: 32) {
            HStack {
                StoreView()
                Spacer()
                
                HStack {
                    Image(systemName: "person.fill")
                    Text("\(state.participantCount)")
                }
                .foregroundColor(.white)
                .padding(.all, 4)
                .padding(.horizontal, 8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(16)
                
                Button {
                    call.leave()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            Text("Text showing info about the product")
                .bold()
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundColor(.white)
                .padding(.horizontal)
                .overlay(
                    HStack {
                        Button(action: {
                            withAnimation {
                                vouchersShown.toggle()
                            }
                        }, label: {
                            Text("Vouchers")
                                .font(.headline)
                                .padding()
                                .padding(.vertical, 4)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        })
                        Spacer()
                    }
                    .offset(x: -16, y: 40)
                )
            
            GeometryReader { reader in
                if let first = state.participants.first {
                    VideoRendererView(id: first.id, size: reader.size) { renderer in
                        renderer.handleViewRendering(for: first) { size, participant in }
                    }
                    .clipShape(CircleRectangleShape())
                } else {
                    Color(UIColor.secondarySystemBackground)
                        .clipShape(CircleRectangleShape())
                }
            }
        }
        .overlay(
            ZStack {
                VStack {
                    LivestreamChatView(
                        chatClient: chatClient,
                        call: call,
                        livestreamId: call.callId,
                        pinnedProduct: pinnedProduct,
                        pinnedProductShown: $pinnedProductShown,
                        productsViewShown: $productsViewShown
                    )
                    .padding()
                    
                    if isHost {
                        ZStack {
                            if call.state.backstage {
                                Button {
                                    Task {
                                        try await call.goLive()
                                    }
                                } label: {
                                    Text("Go Live")
                                        .addButtonStyle()
                                }
                            } else {
                                Button {
                                    Task {
                                        try await call.stopLive()
                                    }
                                } label: {
                                    Text("Stop Livestream")
                                        .addButtonStyle()
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }
                
                if pinnedProductShown {
                    VStack {
                        Spacer()
                        LivestreamProductView(product: pinnedProduct, productInfoShown: $pinnedProductShown)
                    }
                }
                
                if productsViewShown {
                    VStack {
                        Spacer()
                        LivestreamProductsView(productsViewShown: $productsViewShown)
                            .frame(height: .defaultPopupHeight)
                    }
                }
                
                if vouchersShown {
                    VStack {
                        Spacer()
                        LivestreamVouchersView()
                            .frame(height: UIScreen.main.bounds.height / 2 - 50)
                    }
                }
            }

        )
        .background(
            LinearGradient(
                gradient: .init(colors: [.green, .darkGreen]), startPoint: .leading, endPoint: .trailing
            )
            .edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .onAppear {
            Task {
                try await call.join(create: isHost)
            }
        }
        .onDisappear {
            call.leave()
        }
    }
}

struct StoreView: View {
    var body: some View {
        HStack {
            Circle().fill(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Store name")
                    .font(.headline)
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                    Text("4.6K")
                }
            }
            .foregroundColor(.white)
            
            Button(action: {
                print("Follow tapped")
            }, label: {
                Text("+ Follow")
                    .addButtonStyle()
            })
        }
        .padding(.all, 4)
        .background(Color.black.opacity(0.3))
        .cornerRadius(32)
    }
}

extension CGFloat {
    static let defaultPopupHeight = 3 * UIScreen.main.bounds.height / 5
}
