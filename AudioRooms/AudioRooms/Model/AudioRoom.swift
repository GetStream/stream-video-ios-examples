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
    init?(from dict: [String: Any], id: String) {
        self.id = id
        guard dict.keys.contains("title"), let title = dict["title"] as? String else {
            return nil
        }
        self.title = title
        
        guard dict.keys.contains("description"), let description = dict["description"] as? String else { return nil }
        self.subtitle = description
        
        guard dict.keys.contains("hosts"),
              let hostsDict = dict["hosts"] as? [[String: String]] else { return nil }
        self.hosts = hostsDict.compactMap({ hostsDict in
            guard hostsDict.keys.contains("id"),
                  hostsDict.keys.contains("name"),
                  hostsDict.keys.contains("imageUrl"),
                  let hostId = hostsDict["id"],
                  let hostName = hostsDict["name"],
                  let hostImageUrl = hostsDict["imageUrl"]
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

protocol AudioRoomRepository {
    
    func loadAudioRooms() async -> [AudioRoom]
    
}

class DemoAudioRoomRepository: AudioRoomRepository {
    
    private let martin = User.builtInUsersByID(id: "martin")!
    private let tommaso = User.builtInUsersByID(id: "oliver.lazoroski@getstream.io")!
    private let thierry = User.builtInUsersByID(id: "thierry")!
    private let filip = User.builtInUsersByID(id: "filip")!
    private let marcelo = User.builtInUsersByID(id: "marcelo")!
    
    func loadAudioRooms() async -> [AudioRoom] {
        let footballRoom = AudioRoom(
            id: "audioSample1",
            title: "The football room",
            subtitle: "All about the beautiful game",
            hosts: [martin.asHost, thierry.asHost]
        )
        let iOSRoom = AudioRoom(
            id: "audioSample2",
            title: "iOS developers",
            subtitle: "Learn everything about Apple's platforms",
            hosts: [martin.asHost, tommaso.asHost]
        )
        let goRoom = AudioRoom(
            id: "audioSample3",
            title: "Go developers",
            subtitle: "We love Go",
            hosts: [marcelo.asHost, tommaso.asHost]
        )
        let balkanPeople = AudioRoom(
            id: "audioSample4",
            title: "Balkan people",
            subtitle: "Tales from the crazy region",
            hosts: [filip.asHost, martin.asHost]
        )
        return [balkanPeople, footballRoom, iOSRoom, goRoom]
    }
    
}

extension User {
    
    var asHost: User {
        User(
            id: id,
            name: name,
            imageURL: imageURL,
            role: "host",
            extraData: extraData
        )
    }
    
}
