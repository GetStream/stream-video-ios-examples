//
//  User+Dictionary.swift
//  AudioRooms
//
//  Created by Stefan Blos on 28.04.23.
//

import StreamVideo

extension User {
    func toDict() -> [String: RawJSON] {
        return [
            "id": .string(id),
            "name": .string(name),
            "imageUrl": .string(self.imageURL?.absoluteString ?? "https://getstream.io/random_png/?id=\(id)&name=\(name)")
        ]
    }
}
