//
//  LivestreamProductView.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 7.8.24.
//

import SwiftUI

struct LivestreamProductView: View {
    
    let product: Product
    
    @Binding var productInfoShown: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            if #available(iOS 15.0, *) {
                AsyncImage(url: product.imageURL)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(16)
                    .padding()
            }
            
            Text("Some more product info and description")
                .bold()
                .padding()
            
            HStack {
                Text("Flash sale")
                    .bold()
                Spacer()
                Text("Ends soon")
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.orange)
            
            ProductInfoView(product: product, showImage: false)
                .padding()
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            productInfoShown = false
                        }
                    }, label: {
                        Image(systemName: "xmark")
                    })
                    .padding()
                }
                Spacer()
            }
        )
    }
}
