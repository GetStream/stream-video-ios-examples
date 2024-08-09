//
//  Product.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 7.8.24.
//

import Foundation

struct Product: Identifiable {
    let title: String
    let description: String
    let originalPrice: PriceInfo
    let discountedPrice: PriceInfo
    let imageURL: URL?
    
    var reducedPricePercentage: Int {
        let ratio = (1 - (discountedPrice.amount / originalPrice.amount)) * 100
        return Int(ratio)
    }
    
    var id: String {
        "\(title)-\(description)"
    }
}

struct PriceInfo {
    let amount: CGFloat
    let currency: String
    
    var display: String {
        "\(currency)\(amount)"
    }
}

extension Product {
    static let all: [Product] = [.default, .default1, .default2, .default3, .default4]
    static let `default` = Product(
        title: "Test product",
        description: "The test product's description",
        originalPrice: .init(amount: 100, currency: "$"),
        discountedPrice: .init(amount: 75, currency: "$"),
        imageURL: URL(string: "https://img.buzzfeed.com/buzzfeed-static/static/2019-04/23/12/asset/buzzfeed-prod-web-03/sub-buzz-17540-1556035946-1.jpg?downsize=200:*&output-format=auto&output-quality=auto")
    )
    static let default1 = Product(
        title: "Test product 1",
        description: "The test product's description 1",
        originalPrice: .init(amount: 80, currency: "$"),
        discountedPrice: .init(amount: 65, currency: "$"),
        imageURL: URL(string: "https://img.buzzfeed.com/buzzfeed-static/static/2019-04/23/12/asset/buzzfeed-prod-web-03/sub-buzz-17540-1556035946-1.jpg?downsize=200:*&output-format=auto&output-quality=auto")
    )
    static let default2 = Product(
        title: "Test product 2",
        description: "The test product's description 2",
        originalPrice: .init(amount: 110, currency: "$"),
        discountedPrice: .init(amount: 95, currency: "$"),
        imageURL: URL(string: "https://img.buzzfeed.com/buzzfeed-static/static/2019-04/23/12/asset/buzzfeed-prod-web-03/sub-buzz-17540-1556035946-1.jpg?downsize=200:*&output-format=auto&output-quality=auto")
    )
    static let default3 = Product(
        title: "Test product 3",
        description: "The test product's description",
        originalPrice: .init(amount: 100, currency: "$"),
        discountedPrice: .init(amount: 75, currency: "$"),
        imageURL: URL(string: "https://img.buzzfeed.com/buzzfeed-static/static/2019-04/23/12/asset/buzzfeed-prod-web-03/sub-buzz-17540-1556035946-1.jpg?downsize=200:*&output-format=auto&output-quality=auto")
    )
    static let default4 = Product(
        title: "Test product 4",
        description: "The test product's description 4",
        originalPrice: .init(amount: 100, currency: "$"),
        discountedPrice: .init(amount: 75, currency: "$"),
        imageURL: URL(string: "https://img.buzzfeed.com/buzzfeed-static/static/2019-04/23/12/asset/buzzfeed-prod-web-03/sub-buzz-17540-1556035946-1.jpg?downsize=200:*&output-format=auto&output-quality=auto")
    )
}
