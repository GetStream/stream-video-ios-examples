//
//  LivestreamVouchersView.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 7.8.24.
//

import SwiftUI

struct LivestreamVouchersView: View {
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    ForEach(Voucher.all) { voucher in
                        VStack(alignment: .leading) {
                            Text("Follow me to get a voucher")
                                .font(.headline)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(voucher.title)
                                            .bold()
                                        Text(voucher.subtitle)
                                            .font(.subheadline)
                                    }
                                    Button(action: {
                                        print("claim tapped")
                                    }, label: {
                                        Text("Claim")
                                            .addButtonStyle()
                                    })
                                }
                                
                                Text(voucher.validity)
                                    .font(.caption)
                                    .padding(.vertical)
                            }
                            .padding()
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(16)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.leading)
            .padding(.vertical)
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: .init(colors: [Color.pink, Color.white, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
    }
}

struct Voucher: Identifiable {
    let title: String
    let subtitle: String
    let validity: String
    var id: String {
        "\(title)-\(subtitle)-\(validity)"
    }
}

extension Voucher {
    static let first = Voucher(
        title: "Get 50% off",
        subtitle: "For orders over $100",
        validity: "Valid for 1 day after claiming"
    )
    static let second = Voucher(
        title: "Get 25% off",
        subtitle: "For orders over $50",
        validity: "Valid for 1 day after claiming"
    )
    static let all: [Voucher] = [first, second]
}
