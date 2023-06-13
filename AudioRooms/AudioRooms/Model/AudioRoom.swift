//
//  AudioRoom.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import Foundation
import StreamVideo

struct AudioRoom: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let hosts: [User]
}

extension AudioRoom {
    init?(from dict: [String: RawJSON], id: String) {
        guard
            let title = dict["title"]?.stringValue,
            let description = dict["description"]?.stringValue,
            let hostsDict = dict["hosts"]?.arrayValue?.compactMap(\.dictionaryValue)
        else {
            return nil
        }
        self.id = id
        self.title = title
        self.subtitle = description
        self.hosts = hostsDict.compactMap(User.init)
    }
}

extension AudioRoom {
    static var preview: AudioRoom = AudioRoom(
        id: "audioSample1",
        title: "The football room",
        subtitle: "All about the beautiful game",
        hosts: [
            User.builtInUsersByID(id: "martin")!,
            User.builtInUsersByID(id: "thierry")!
        ]
    )
}

extension AudioRoom {
    var callId: String {
        if id.contains("audio_room:") {
            return "\(id.split(separator: ":")[1])"
        } else {
            return id
        }
    }
}

extension User {

    init?(_ dictionary: [String: RawJSON]) {
        guard
            let hostId = dictionary["id"]?.stringValue,
            let hostName = dictionary["name"]?.stringValue,
            let hostImageUrl = dictionary["imageUrl"]?.stringValue
        else {
            return nil
        }
        self = .init(
            id: hostId,
            name: hostName,
            imageURL: URL(string: hostImageUrl)
        )
    }
}

extension User {

    var member: Member { .init(user: self) }
}
