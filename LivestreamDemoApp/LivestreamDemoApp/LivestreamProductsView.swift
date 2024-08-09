//
//  LivestreamProductsView.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 7.8.24.
//

import SwiftUI

struct LivestreamProductsView: View {
    
    @State var selectedProduct: Product?
    @State var productInfoShown: Bool = false
    @Binding var productsViewShown: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(Product.all) { product in
                    ProductInfoView(product: product) {
                        withAnimation {
                            selectedProduct = product
                            productInfoShown = true
                        }
                    }
                }
            }
            .padding()
            .padding(.top)
        }
        .background(Color.white)
        .cornerRadius(16)
        .onChange(of: productInfoShown, perform: { value in
            if !value {
                withAnimation {
                    selectedProduct = nil
                }
            }
        })
        .overlay(
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                productsViewShown = false
                            }
                        }, label: {
                            Image(systemName: "xmark")
                        })
                        .padding()
                    }
                    Spacer()
                }
                
                selectedProduct != nil ? LivestreamProductView(
                    product: selectedProduct!, productInfoShown: $productInfoShown
                )
                .frame(height: .defaultPopupHeight)
                : nil
            }
        )
    }
}
