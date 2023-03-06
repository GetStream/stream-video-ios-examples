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
    static var preview: AudioRoom = AudioRoom(
        id: "sampleAudioRoom1",
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
            id: "sampleAudioRoom1",
            title: "The football room",
            subtitle: "All about the beautiful game",
            hosts: [martin.asHost, thierry.asHost]
        )
        let iOSRoom = AudioRoom(
            id: "sampleAudioRoom2",
            title: "iOS developers",
            subtitle: "Learn everything about Apple's platforms",
            hosts: [martin.asHost, tommaso.asHost]
        )
        let goRoom = AudioRoom(
            id: "sampleAudioRoom3",
            title: "Go developers",
            subtitle: "We love Go",
            hosts: [marcelo.asHost, tommaso.asHost]
        )
        let balkanPeople = AudioRoom(
            id: "sampleAudioRoom4",
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
