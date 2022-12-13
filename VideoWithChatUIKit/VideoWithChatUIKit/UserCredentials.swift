//
//  UserCredentials.swift
//  VideoWithChatUIKit
//
//  Created by Martin Mitrevski on 13.12.22.
//

import Foundation
import StreamVideo
import StreamChat

struct UserCredentials: Identifiable, Codable {
    var id: String {
        user.id
    }
    let user: User
    let tokenValue: String
}

extension UserCredentials {
    var videoToken: UserToken {
        try! UserToken(rawValue: tokenValue)
    }
}

extension UserCredentials {
    
    static func builtInUsersByID(id: String) -> UserCredentials? {
        builtInUsers.filter { $0.id == id }.first
    }
    
    static var builtInUsers: [UserCredentials] = [
        (
            "martin",
            "Martin",
            "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/802d2/martin-mitrevski.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tZ29AdjAuMS4wIiwic3ViIjoidXNlci9tYXJ0aW4iLCJpYXQiOjE2NzAxODg5ODQsInVzZXJfaWQiOiJtYXJ0aW4ifQ.aG3P_YqukrQZi50kkQqoc_GrzY38jnFVjYWDGbzrwDQ"
        ),
        (
            "tommaso",
            "Tommaso",
            "https://getstream.io/static/712bb5c0bd5ed8d3fa6e5842f6cfbeed/c59de/tommaso.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tZ29AdjAuMS4wIiwic3ViIjoidXNlci90b21tYXNvIiwiaWF0IjoxNjcwMTg5MDQ4LCJ1c2VyX2lkIjoidG9tbWFzbyJ9.kKv0Mmz9i_30z2JnjOaz2qEMsUgDVJvSzRK5LRJqg_Q"
        ),
        (
            "marcelo",
            "Marcelo",
            "https://getstream.io/static/aaf5fb17dcfd0a3dd885f62bd21b325a/802d2/marcelo-pires.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tZ29AdjAuMS4wIiwic3ViIjoidXNlci9tYXJjZWxvIiwiaWF0IjoxNjcwMTg5MDkzLCJ1c2VyX2lkIjoibWFyY2VsbyJ9.PiHt0EFmhwO5AfOnb8zYWpepopILwDcpvsx9LjyAYlw"
        ),
        (
            "filip",
            "Filip",
            "https://getstream.io/static/76cda49669be38b92306cfc93ca742f1/802d2/filip-babi%C4%87.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tZ29AdjAuMS4wIiwic3ViIjoidXNlci9maWxpcCIsImlhdCI6MTY3MDE4OTExNywidXNlcl9pZCI6ImZpbGlwIn0.A7tzKGUyMChz4CZVzoTdPEHGUA9OLcpy9MrcaJJi_lo"
        ),
        (
            "thierry",
            "Thierry",
            "https://getstream.io/static/237f45f28690696ad8fff92726f45106/c59de/thierry.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tZ29AdjAuMS4wIiwic3ViIjoidXNlci90aGllcnJ5IiwiaWF0IjoxNjcwMTg5MTM1LCJ1c2VyX2lkIjoidGhpZXJyeSJ9.SQwpOYUCsykWKGhbiEMKlhwtZ6okLWFs_X2CCnHXIfQ"
        ),
        (
            "sam",
            "Sam",
            "https://getstream.io/static/379eda22663bae101892ad1d37778c3d/802d2/samuel-jeeves.webp",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tZ29AdjAuMS4wIiwic3ViIjoidXNlci9zYW0iLCJpYXQiOjE2NzAxODkxNTMsInVzZXJfaWQiOiJzYW0ifQ.8L9xzAsrYeOat1WeVAAMZpp7iesqkWATuYDwaTnPMdA"
        )
    ].map {
        UserCredentials(
            user: User(
                id: $0.0,
                name: $0.1,
                imageURL: URL(string: $0.2)!,
                extraData: [:]
            ),
            tokenValue: $0.3
        )
    }
}

