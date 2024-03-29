//
//  AudioRoom.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import Foundation
import StreamVideo

@MainActor
struct AudioRoom: Identifiable {
    enum AudioRoomType: CaseIterable, CustomStringConvertible, Hashable {
        case live
        case upcoming
        case ended

        var description: String {
            switch self {
            case .live:
                return "Live"
            case .upcoming:
                return "Upcoming"
            case .ended:
                return "Ended"
            }
        }
    }

    let id: String
    let title: String
    let subtitle: String
    let hosts: [User]
    let type: AudioRoomType
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
        self.type = {
            if dict["backstage"]?.boolValue == false {
                return .live
            } else if dict["ended_at"]?.stringValue != nil {
                return .ended
            } else {
                return .upcoming
            }
        }()
    }

    init?(from call: Call) {
        guard
            let title = call.state.custom["title"]?.stringValue,
            let description = call.state.custom["description"]?.stringValue,
            let hostsDict = call.state.custom["hosts"]?.arrayValue?.compactMap(\.dictionaryValue)
        else {
            return nil
        }

        self.id = call.cId
        self.title = title
        self.subtitle = description
        self.hosts = hostsDict.compactMap(User.init)
        self.type = {
            if call.state.backstage == false {
                return .live
            } else if call.state.endedAt != nil {
                return .ended
            } else {
                return .upcoming
            }
        }()
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
        ],
        type: .live
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

    var memberRequest: MemberRequest { .init(custom: customData, role: role,  userId: id) }
}
