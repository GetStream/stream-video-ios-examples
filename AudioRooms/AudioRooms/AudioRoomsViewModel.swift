//
//  AudioRoomsViewModel.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import Foundation
import SwiftUI

@MainActor
class AudioRoomsViewModel: ObservableObject {
    
    @Published var audioRooms = [AudioRoom]()
    @Published var selectedAudioRoom: AudioRoom?
    @Published var logoutAlertShown = false
    
    private let repository: AudioRoomRepository = DemoAudioRoomRepository()
    
    init() {
        loadAudioRooms()
    }
    
    private func loadAudioRooms() {
        Task {
            self.audioRooms = await repository.loadAudioRooms()
        }
    }
    
}
