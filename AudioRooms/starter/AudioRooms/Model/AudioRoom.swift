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
        id: "audioroom1",
        title: "The football room",
        subtitle: "All about the beautiful game",
        hosts: [
            UserCredentials.builtInUsersByID(id: "martin")!.userInfo,
            UserCredentials.builtInUsersByID(id: "thierry")!.userInfo
        ]
    )
}

protocol AudioRoomRepository {
    
    func loadAudioRooms() async -> [AudioRoom]
    
}

class DemoAudioRoomRepository: AudioRoomRepository {
    
    private let martin = UserCredentials.builtInUsersByID(id: "martin")!.userInfo
    private let tommaso = UserCredentials.builtInUsersByID(id: "oliver.lazoroski@getstream.io")!.userInfo
    private let thierry = UserCredentials.builtInUsersByID(id: "thierry")!.userInfo
    private let filip = UserCredentials.builtInUsersByID(id: "filip")!.userInfo
    private let marcelo = UserCredentials.builtInUsersByID(id: "marcelo")!.userInfo
    
    func loadAudioRooms() async -> [AudioRoom] {
        let footballRoom = AudioRoom(
            id: "audioroom111111",
            title: "The football room",
            subtitle: "All about the beautiful game",
            hosts: [martin.asHost, thierry.asHost]
        )
        let iOSRoom = AudioRoom(
            id: "audioroom111112",
            title: "iOS developers",
            subtitle: "Learn everything about Apple's platforms",
            hosts: [martin.asHost, tommaso.asHost]
        )
        let goRoom = AudioRoom(
            id: "audioroom111113",
            title: "Go developers",
            subtitle: "We love Go",
            hosts: [marcelo.asHost, tommaso.asHost]
        )
        let balkanPeople = AudioRoom(
            id: "audioroom111114",
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
