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

    init() {
        Task {
            self.audioRooms = await DemoAudioRoomRepository().loadAudioRooms()
        }
    }
}

