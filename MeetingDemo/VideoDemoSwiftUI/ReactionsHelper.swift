//
//  ReactionsHelper.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 17.2.23.
//

import Foundation
import SwiftUI
import StreamVideo
import AVFoundation

@MainActor
class ReactionsHelper: ObservableObject {
    
    static let shared = ReactionsHelper()
    
    @Injected(\.streamVideo) var streamVideo
    
    var player: AVAudioPlayer?
    
    @Published var reactionsShown = false
    @Published var showFireworks = false
    @Published var availableReactions: [Reaction] = [
        Reaction(id: "fireworks", sound: "cheer", iconName: "party.popper.fill"),
        Reaction(id: "raiseHand", userSpecific: true, iconName: "hand.raised.fill"),
        Reaction(id: "like", duration: 5, userSpecific: true, iconName: "hand.thumbsup.fill")
    ]
    @Published var raisedHandsIds = Set<String>()
    @Published var likeReactionIds = Set<String>()
    
    var callId: String?
    var callType: CallType?
    
    private init() {
        subscribeToCustomEvents()
    }
    
    private lazy var eventsController: EventsController = {
        streamVideo.makeEventsController()
    }()
    
    func send(reaction: Reaction) {
        guard let callId, let callType else { return }
        Task {
            let customEvent = CustomEventRequest(
                callId: callId,
                callType: callType,
                type: .reaction,
                extraData: [
                    "id": .string(reaction.id),
                    "duration": .number(reaction.duration ?? 0),
                    "sound": .string(reaction.sound ?? ""),
                    "userSpecific": .bool(reaction.userSpecific),
                    "isReverted": .bool(shouldRevert(reaction: reaction))
                ]
            )
            try await eventsController.send(event: customEvent)
        }
    }
    
    func shouldRevert(reaction: Reaction) -> Bool {
        reaction.id == "raiseHand" && raisedHandsIds.contains(streamVideo.user.id)
    }
    
    func removeRaisedHand(from userId: String) {
        raisedHandsIds.remove(userId)
    }
    
    func playSound(soundName: String) {
        guard let url = Bundle.main.url(
            forResource: soundName,
            withExtension: "mp3"
        ) else { return }
        self.player = try? AVAudioPlayer(contentsOf: url)
        self.player?.numberOfLoops = 0
        self.player?.volume = 0.5
        self.player?.play()
    }
    
    private func subscribeToCustomEvents() {
        Task {
            for await event in eventsController.customEvents() {
                log.debug("received an event \(event)")
                if event.type == EventType.reaction.rawValue {
                    handleReaction(with: event.extraData, from: event.user)
                }
                checkSounds(with: event.extraData)
            }
        }        
    }
    
    private func handleReaction(with info: [String: Any], from user: User) {
        guard let id = info["id"] as? String else { return }
        if id == "fireworks" {
            handleFireworksReaction(with: info, from: user)
        } else if id == "raiseHand" {
            handleRaiseHandReaction(with: info, from: user)
        } else if id == "like" {
            handleLikeReaction(with: info, from: user)
        }
    }
    
    private func handleFireworksReaction(with info: [String: Any], from user: User) {
        self.showFireworks = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.showFireworks = false
        })
    }
    
    private func handleRaiseHandReaction(with info: [String: Any], from user: User) {
        if let isReverted = info["isReverted"] as? Bool, isReverted == true {
            raisedHandsIds.remove(user.id)
        } else {
            raisedHandsIds.insert(user.id)
        }
    }
    
    private func handleLikeReaction(with info: [String: Any], from user: User) {
        likeReactionIds.insert(user.id)
        let duration: Double = info["duration"] as? Double ?? 2.5
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            self.likeReactionIds.remove(user.id)
        })
    }
    
    private func checkSounds(with info: [String: Any]) {
        if let sound = info["sound"] as? String, !sound.isEmpty {
            playSound(soundName: sound)
        }
    }
    
}

extension EventType {
    static let reaction: Self = "reaction"
}

struct Reaction: Identifiable, Codable {
    var id: String
    var duration: Double?
    var sound: String?
    var userSpecific: Bool = false
    var iconName: String
}
