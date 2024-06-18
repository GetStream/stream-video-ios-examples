//
//  TokenService.swift
//  DemoApp
//
//  Created by Martin Mitrevski on 2.3.23.
//

import Foundation
import StreamVideo

enum AuthenticationProvider {

    @MainActor
    static func fetchToken(
        for userId: String,
        callIds: [String] = []
    ) async throws -> (apiKey: String, token: UserToken) {
        let environment = "demo"

        var url = URL(string: "https://pronto.getstream.io/api/auth/create-token")!
            .appending(.init(name: "user_id", value: userId))
            .appending(.init(name: "environment", value: environment))

        if !callIds.isEmpty {
            url = url.appending(
                URLQueryItem(
                    name: "call_cids",
                    value: callIds.joined(separator: ",")
                )
            )
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        let token = UserToken(rawValue: tokenResponse.token)
        log.debug("Authentication info userId:\(tokenResponse.userId) apiKey:\(tokenResponse.apiKey) token:\(token)")
        return (tokenResponse.apiKey, token)
    }
}

struct TokenResponse: Codable {
    let userId: String
    let token: String
    let apiKey: String
}

extension URL {

    func appending(_ queryItem: URLQueryItem) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = (components.queryItems ?? []) + [queryItem]

        return components.url ?? self
    }

    var host: String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?.host
    }
}
