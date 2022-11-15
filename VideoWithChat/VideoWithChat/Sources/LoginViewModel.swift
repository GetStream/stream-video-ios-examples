//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamVideo
import StreamChat

@MainActor
class LoginViewModel: ObservableObject {
        
    @Published var loading = false
    
    @Published var userCredentials = UserCredentials.builtInUsers
    
    func login(user: UserCredentials, completion: (UserCredentials) -> ()) {
        UnsecureUserRepository.shared.save(user: user)
        AppState.shared.currentUser = user.user
        AppState.shared.userState = .loggedIn
        // Perform login
        completion(user)
    }
    
}

struct UserCredentials: Identifiable, Codable {
    var id: String {
        user.id
    }
    let user: User
    let videoTokenValue: String
    let chatTokenValue: String
}

extension UserCredentials {
    var videoToken: UserToken {
        try! UserToken(rawValue: videoTokenValue)
    }
}

extension UserCredentials {
    
    static func builtInUsersByID(id: String) -> UserCredentials? {
        builtInUsers.filter { $0.id == id }.first
    }
    
    static var builtInUsers: [UserCredentials] = [
        (
            "tommaso",
            "Tommaso",
            "https://getstream.io/static/712bb5c0bd5ed8d3fa6e5842f6cfbeed/c59de/tommaso.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tanNAdjAuMC4wIiwic3ViIjoidXNlci90b21tYXNvIiwiaWF0IjoxNjY4MDc4MDEsInVzZXJfaWQiOiJ0b21tYXNvIn0.lOzf0aZ80tKR438N6H5usitSJoWNy97zY1mT8xcXujc",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidG9tbWFzbyJ9.BR8YNU3H-l19anEPyqOV_-QMjuiHuHrTlSxURuhhUww"
        ),
        (
            "marcelo",
            "Marcelo",
            "https://getstream.io/static/aaf5fb17dcfd0a3dd885f62bd21b325a/802d2/marcelo-pires.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tanNAdjAuMC4wIiwic3ViIjoidXNlci9tYXJjZWxvIiwiaWF0IjoxNjY4MDc4MDMsInVzZXJfaWQiOiJtYXJjZWxvIn0.c2ph9oPZL8qGP-Tz4cJwmg3RL8Z6v1uYlL6dibwm_94",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibWFyY2VsbyJ9.COCPmaoUnAPd9A878PMdaUHPMEGC1hBaH00E0Zpg_kM"
        ),
        (
            "martin",
            "Martin",
            "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/802d2/martin-mitrevski.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tanNAdjAuMC4wIiwic3ViIjoidXNlci9tYXJ0aW4iLCJpYXQiOjE2NjgwNzc1MiwidXNlcl9pZCI6Im1hcnRpbiJ9.mOqr4LFFXmtyuji7RkmlOimwETTGSQ4tXNdDEYL8FZ8",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibWFydGluIn0.0NAr8OopmBFlLwMiSiP4x9RDZ0LbrN4D_cPCb1T2TRo"
        ),
        (
            "filip",
            "Filip",
            "https://getstream.io/static/76cda49669be38b92306cfc93ca742f1/802d2/filip-babi%C4%87.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tanNAdjAuMC4wIiwic3ViIjoidXNlci9maWxpcCIsImlhdCI6MTY2ODA3ODA0LCJ1c2VyX2lkIjoiZmlsaXAifQ.U2L5rh9S0vFY3M7wmoONbcbacppduzA6mJVktUC4UKA",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZmlsaXAifQ.kwcTuoRPyssP10OKtns7ZqN3945F7iukYb5_3Xa5XeA"
        ),
        (
            "thierry",
            "Thierry",
            "https://getstream.io/static/237f45f28690696ad8fff92726f45106/c59de/thierry.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tanNAdjAuMC4wIiwic3ViIjoidXNlci90aGllcnJ5IiwiaWF0IjoxNjY4MDc4MDYsInVzZXJfaWQiOiJ0aGllcnJ5In0.vRtZsOaJeCcK9CqcMAGqDpzIvPNH5n2Mwcfc0WCNlFM",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidGhpZXJyeSJ9.klAUWSO3F4thKR2GxS0M5om8nCRJmQFLANPK6cm3I6c"
        ),
        (
            "sam",
            "Sam",
            "https://getstream.io/static/379eda22663bae101892ad1d37778c3d/802d2/samuel-jeeves.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tanNAdjAuMC4wIiwic3ViIjoidXNlci9zYW0iLCJpYXQiOjE2NjgwNzgwNywidXNlcl9pZCI6InNhbSJ9.j0tobH1R3_ujFMlA4FApT3uOijp1jVxgOAVuIu1I8-Y",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoic2FtIn0.9brB2KmBhhq0GlNvP-d_tp3D9Wjh-CwiXkCxBRq2QpM"
        )
    ].map {
        UserCredentials(
            user: User(
                id: $0.0,
                name: $0.1,
                imageURL: URL(string: $0.2)!,
                extraData: [:]
            ),
            videoTokenValue: $0.3,
            chatTokenValue: $0.4
        )
    }
}
