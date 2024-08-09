//
//  LivestreamChatView.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 6.8.24.
//

import SwiftUI
import class StreamChat.ChatClient
import class StreamVideo.Call

struct LivestreamChatView: View {

    @StateObject var viewModel: LivestreamChatViewModel
    
    private var pinnedProduct: Product
    private let livestreamId: String
    
    @Binding var pinnedProductShown: Bool
    @Binding var productsViewShown: Bool
    
    init(
        chatClient: ChatClient,
        call: Call,
        livestreamId: String,
        pinnedProduct: Product,
        pinnedProductShown: Binding<Bool>,
        productsViewShown: Binding<Bool>
    ) {
        _viewModel = StateObject(
            wrappedValue: LivestreamChatViewModel(
                chatClient: chatClient, 
                call: call,
                livestreamId: livestreamId
            )
        )
        self.pinnedProduct = pinnedProduct
        _pinnedProductShown = pinnedProductShown
        _productsViewShown = productsViewShown
        self.livestreamId = livestreamId
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                ForEach(viewModel.messages, id: \.id) { message in
                    HStack {
                        if #available(iOS 15.0, *) {
                            AsyncImage(url: message.imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle().fill(.gray)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        Text(message.text)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                
                ProductInfoView(product: pinnedProduct, onBuyTap: {
                    withAnimation {
                        pinnedProductShown = true
                    }
                })
                .padding(.all, 8)
                .background(Color.white)
                .cornerRadius(16)
            }
            
            HStack {
                Button {
                    productsViewShown = true
                } label: {
                    Image(systemName: "bag.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
                        .foregroundColor(.yellow)
                }
                
                TextField("Comment", text: $viewModel.text)
                    .textFieldStyle(.roundedBorder)
                    .opacity(0.7)
                
                Button {
                    viewModel.sendMessage(text: viewModel.text)
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
                        .foregroundColor(.pink)
                }
                .disabled(viewModel.text.isEmpty)
                
                // Deep linking should be setup here accordingly.
                ShareButton(content: [URL(string: "https://video-react-livestream-app.vercel.app/viewers/webrtc/\(livestreamId)?api_key=mmhfdzb5evj2&") as Any]
                )
                .padding(.leading)
            }
        }
        .background(Color.clear)
    }
}

struct ProductInfoView: View {
    
    let product: Product
    var showImage: Bool = true
    var onBuyTap: (() -> ())? = nil
    
    var body: some View {
        HStack {
            if #available(iOS 15.0, *), showImage {
                AsyncImage(url: product.imageURL)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
            }
            VStack(alignment: .leading) {
                Text(product.title)
                    .bold()
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                HStack(alignment: .bottom) {
                    Text("\(product.discountedPrice.display)")
                        .font(.headline)
                    Text("\(product.originalPrice.display)")
                        .font(.subheadline)
                        .strikethrough(color: .red)
                        .foregroundColor(.red)
                    Text("(-\(product.reducedPricePercentage)%)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Button(action: {
                onBuyTap?()
            }, label: {
                Text("Buy")
                    .addButtonStyle()
            })
        }
    }
}
