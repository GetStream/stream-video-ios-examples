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
        self.id = id
        guard let title = dict["title"]?.stringValue,
              let description = dict["description"]?.stringValue,
              let hostsDict = dict["hosts"]?.arrayValue else {
            return nil
        }
        self.title = title
        self.subtitle = description
        self.hosts = hostsDict
            .compactMap { $0.dictionaryValue }
            .compactMap({ hostsDict in
            guard let hostId = hostsDict["id"]?.stringValue,
                  let hostName = hostsDict["name"]?.stringValue,
                  let hostImageUrl = hostsDict["imageUrl"]?.stringValue
            else { return nil }
            return User(
                id: hostId,
                name: hostName,
                imageURL: URL(string: hostImageUrl)
            )
        })
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
