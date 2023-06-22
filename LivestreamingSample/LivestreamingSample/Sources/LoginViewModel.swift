//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamVideo

@MainActor
class LoginViewModel: ObservableObject {
    
    let tokenService = TokenService.shared
        
    @Published var loading = false
    
    @Published var users = User.builtInUsers
    
    func login(user: User, completion: (UserCredentials) -> ()) async throws {
        let token = try await self.tokenService.fetchToken(for: user.id)
        let credentials = UserCredentials(user: user, tokenValue: token.rawValue)
        UnsecureUserRepository.shared.save(user: credentials)
        AppState.shared.currentUser = user
        AppState.shared.userState = .loggedIn
        // Perform login
        completion(credentials)
    }
    
    func loginAnonymously(completion: (UserCredentials) -> ()) {
        AppState.shared.currentUser = .anonymous
        AppState.shared.userState = .loggedIn
        completion(.init(user: .anonymous, tokenValue: ""))
    }
    
}

struct UserCredentials: Identifiable, Codable {
    var id: String {
        user.id
    }
    let user: User
    let tokenValue: String
}

extension UserCredentials {
    var videoToken: UserToken { UserToken(rawValue: tokenValue) }
}

extension User {
    
    static func builtInUsersByID(id: String) -> User? {
        builtInUsers.filter { $0.id == id }.first
    }
    
    static var builtInUsers: [User] = [
        (
            "tommaso",
            "Tommaso",
            "https://getstream.io/static/712bb5c0bd5ed8d3fa6e5842f6cfbeed/c59de/tommaso.webp"
        ),
        (
            "marcelo",
            "Marcelo",
            "https://getstream.io/static/aaf5fb17dcfd0a3dd885f62bd21b325a/802d2/marcelo-pires.webp"
        ),
        (
            "martin",
            "Martin",
            "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/802d2/martin-mitrevski.webp"
        ),
        (
            "filip",
            "Filip",
            "https://getstream.io/static/76cda49669be38b92306cfc93ca742f1/802d2/filip-babi%C4%87.webp"
        ),
        (
            "thierry",
            "Thierry",
            "https://getstream.io/static/237f45f28690696ad8fff92726f45106/c59de/thierry.webp"
        ),
        (
            "sam",
            "Sam",
            "https://getstream.io/static/379eda22663bae101892ad1d37778c3d/802d2/samuel-jeeves.webp"
        )
    ].map {
        User(
            id: $0.0,
            name: $0.1,
            imageURL: URL(string: $0.2)!,
            role: "host",
            customData: [:]
        )
    }
}
