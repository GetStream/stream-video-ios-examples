//
//  MeetingViewModel.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 18.1.23.
//

import SwiftUI
import AVFoundation

@MainActor
class MeetingViewModel: ObservableObject {
    
    @Published var meetings = [Meeting]()
    @Published var selectedMeeting: Meeting?
    
    private let meetingsRepository: MeetingsRepository = MeetingsRepositoryMock()
    
    init() {
        Task {
            meetings = await meetingsRepository.loadAllMeetings()
        }
    }
    
}
