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
    static var preview: AudioRoom = DemoAudioRoomRepository.loadAudioRooms().first!
}

protocol AudioRoomRepository {
    
    static func loadAudioRooms() -> [AudioRoom]
    
}

class DemoAudioRoomRepository: AudioRoomRepository {
    
    private static let martin = UserCredentials.builtInUsersByID(id: "martin")!.userInfo
    private static let tommaso = UserCredentials.builtInUsersByID(id: "tommaso")!.userInfo
    private static let thierry = UserCredentials.builtInUsersByID(id: "thierry")!.userInfo
    private static let filip = UserCredentials.builtInUsersByID(id: "filip")!.userInfo
    private static let marcelo = UserCredentials.builtInUsersByID(id: "marcelo")!.userInfo
    
    static func loadAudioRooms() -> [AudioRoom] {
        let footballRoom = AudioRoom(
            id: "audioroom1",
            title: "The football room",
            subtitle: "All about the beautiful game",
            hosts: [martin, thierry]
        )
        let iOSRoom = AudioRoom(
            id: "audioroom2",
            title: "iOS developers",
            subtitle: "Learn everything about Apple's platforms",
            hosts: [martin, tommaso]
        )
        let goRoom = AudioRoom(
            id: "audioroom3",
            title: "Go developers",
            subtitle: "We love Go",
            hosts: [marcelo, tommaso]
        )
        let balkanPeople = AudioRoom(
            id: "audioroom4",
            title: "Balkan people",
            subtitle: "Tales from the crazy region",
            hosts: [filip, martin]
        )
        return [balkanPeople, footballRoom, iOSRoom, goRoom]
    }
    
}
