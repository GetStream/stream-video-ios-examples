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

protocol AudioRoomRepository {
    
    func loadAudioRooms() async -> [AudioRoom]
    
}

class DemoAudioRoomRepository: AudioRoomRepository {
    
    let martin = User(id: "martin", name: "Martin", imageURL: URL(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/802d2/martin-mitrevski.webp"), extraData: [:])
    let tommaso = User(id: "tommaso", name: "Tommaso", imageURL: URL(string: "https://getstream.io/static/712bb5c0bd5ed8d3fa6e5842f6cfbeed/c59de/tommaso.webp"), extraData: [:])
    let thierry = User(id: "thierry", name: "Thierry", imageURL: URL(string: "https://getstream.io/static/237f45f28690696ad8fff92726f45106/c59de/thierry.webp"), extraData: [:])
    let filip = User(id: "filip", name: "Filip", imageURL: URL(string: "https://getstream.io/static/76cda49669be38b92306cfc93ca742f1/802d2/filip-babi%C4%87.webp"), extraData: [:])
    let marcelo = User(id: "marcelo", name: "Marcelo", imageURL: URL(string: "https://getstream.io/static/aaf5fb17dcfd0a3dd885f62bd21b325a/802d2/marcelo-pires.webp"), extraData: [:])
    
    func loadAudioRooms() async -> [AudioRoom] {
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
