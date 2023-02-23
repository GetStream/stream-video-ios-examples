//
//  PermissionsHelper.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 21.2.23.
//

import Foundation
import SwiftUI
import StreamVideo

class PermissionsHelper: ObservableObject {
    
    @Injected(\.streamVideo) var streamVideo
    
    private lazy var permissionsController: PermissionsController = {
        streamVideo.makePermissionsController()
    }()
    
    var currentUserCanEndCall: Bool {
        permissionsController.currentUserHasCapability(.endCall)
    }
    
    var currentUserCanMuteUsers: Bool {
        permissionsController.currentUserHasCapability(.muteUsers)
    }
    
    var showAdminControls: Bool {
        currentUserCanEndCall || currentUserCanMuteUsers
    }
    
    func muteUsers(ids: [String], callId: String, callType: CallType) {
        Task {
            let muteRequest = MuteRequest(
                userIds: ids,
                muteAllUsers: true,
                audio: true,
                video: false,
                screenshare: false
            )
            try await permissionsController.muteUsers(
                with: muteRequest,
                callId: callId,
                callType: callType.name
            )
        }
    }
    
    func endCallForEveryone(callId: String, callType: CallType) {
        Task {
            try await permissionsController.endCall(
                callId: callId,
                callType: callType.name
            )
        }
    }
    
}
