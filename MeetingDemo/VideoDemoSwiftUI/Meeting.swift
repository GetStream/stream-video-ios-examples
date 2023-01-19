//
//  Meeting.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 18.1.23.
//

import Foundation
import StreamVideo

struct Meeting: Identifiable {
    let id: String
    let name: String
    let timeDisplay: String
    let participants: [User]
}

protocol MeetingsRepository {
    
    func loadAllMeetings() async -> [Meeting]
    
}

class MeetingsRepositoryMock: MeetingsRepository {
        
    let martin = User(id: "martin", name: "Martin", imageURL: URL(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/802d2/martin-mitrevski.webp"), extraData: [:])
    let tommaso = User(id: "tommaso", name: "Tommaso", imageURL: URL(string: "https://getstream.io/static/712bb5c0bd5ed8d3fa6e5842f6cfbeed/c59de/tommaso.webp"), extraData: [:])
    let thierry = User(id: "thierry", name: "Thierry", imageURL: URL(string: "https://getstream.io/static/237f45f28690696ad8fff92726f45106/c59de/thierry.webp"), extraData: [:])
    let filip = User(id: "filip", name: "Filip", imageURL: URL(string: "https://getstream.io/static/76cda49669be38b92306cfc93ca742f1/802d2/filip-babi%C4%87.webp"), extraData: [:])
    let marcelo = User(id: "marcelo", name: "Marcelo", imageURL: URL(string: "https://getstream.io/static/aaf5fb17dcfd0a3dd885f62bd21b325a/802d2/marcelo-pires.webp"), extraData: [:])
    
    func loadAllMeetings() async -> [Meeting] {
        return [
            Meeting(
                id: UUID().uuidString,
                name: "Daily Standup",
                timeDisplay: "Every day, 09:15",
                participants: [martin, marcelo, filip]
            ),
            Meeting(
                id: UUID().uuidString,
                name: "Sprint Planning",
                timeDisplay: "Every second Monday, 11:00",
                participants: [martin, marcelo, filip, tommaso, thierry]
            ),
            Meeting(
                id: UUID().uuidString,
                name: "Sprint Retro",
                timeDisplay: "Every second Friday, 11:00",
                participants: [martin, marcelo, filip, tommaso, thierry]
            ),
            Meeting(
                id: UUID().uuidString,
                name: "Backlog refinement",
                timeDisplay: "Every second Tuesday, 11:00",
                participants: [martin, tommaso, thierry]
            ),
            Meeting(
                id: UUID().uuidString,
                name: "One on one",
                timeDisplay: "Every Wednesday, 14:00",
                participants: [martin, filip]
            )
        ]
    }
    
}
