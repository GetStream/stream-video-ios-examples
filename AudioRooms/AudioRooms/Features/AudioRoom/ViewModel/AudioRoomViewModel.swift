//
//  AudioRoomViewModel.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 30.1.23.
//

import Combine
import SwiftUI
import StreamVideo

@MainActor
class AudioRoomViewModel: ObservableObject {
    
    @Injected(\.streamVideo) var streamVideo
    
    @Published var callViewModel = CallViewModel()
    
    @Published var hosts = [CallParticipant]()
    @Published var otherUsers = [CallParticipant]()
    
    @Published var hasPermissionsToSpeak = false
    @Published var isUserMuted = true
    @Published var loading = true
    @Published var permissionPopupShown = false
    @Published var revokePermissionPopupShown = false
    @Published var activeCallPermissions = [String: [String]]() {
        didSet {
            hasPermissionsToSpeak = activeCallPermissions[streamVideo.user.id]?.contains("send-audio") == true
                || isCurrentUserHost
        }
    }
    @Published var isCallLive = false
    @Published var callEnded = false
    var revokingParticipant: CallParticipant? {
        didSet {
            if revokingParticipant != nil {
                revokePermissionPopupShown = true
            }
        }
    }
    
    var permissionRequest: PermissionRequest? {
        didSet {
            permissionPopupShown = permissionRequest != nil
        }
    }
    
    var call: Call {
        get throws {
            if let call = callViewModel.call {
                return call
            } else {
                throw ClientError.Unknown()
            }
        }
    }
    
    private let audioRoom: AudioRoom
    private var cancellables = Set<AnyCancellable>()
    private let callType: String = .audioRoom
    
    init(audioRoom: AudioRoom) {
        self.audioRoom = audioRoom
        checkAudioSettings()
        callViewModel.startCall(
            callId: audioRoom.callId,
            type: callType,
            members: audioRoom.hosts
        )
        subscribeForParticipantChanges()
        subscribeForAudioChanges()
        subscribeForCallStateChanges()
    }
    
    func leaveCall() {
        callViewModel.hangUp()
    }
    
    func raiseHand() {
        Task {
            try await call.request(permissions: [.sendAudio])
        }
    }
    
    func grantUserPermissions() {
        guard let permissionRequest else { return }
        Task {
            try await call.grant(
                permissions: permissionRequest.permissions.compactMap { Permission(rawValue: $0) },
                for: permissionRequest.user.id
            )
        }
    }
    
    func revokePermissions() {
        guard let revokingParticipant else { return }
        Task {
            try await call.revoke(
                permissions: [.sendAudio],
                for: revokingParticipant.userId
            )
        }
    }
    
    func canAskForAudioPermission() -> Bool {
        do {
            return try call.currentUserCanRequestPermissions([.sendAudio])
        } catch {
            return false
        }
    }
    
    func changeMuteState() {
        callViewModel.toggleMicrophoneEnabled()
    }
    
    func goLive() {
        Task {
            try await call.goLive()
        }
    }
    
    func stopLive() {
        Task {
            try await call.stopLive()
        }
    }
    
    var showGoLiveButton: Bool {
        do {
            return try call.currentUserHasCapability(.updateCall) && !isCallLive
        } catch {
            return false
        }
    }
    
    var showStopLiveButton: Bool {
        do {
            return try call.currentUserHasCapability(.updateCall) && isCallLive
        } catch {
            return false
        }
    }
    
    //MARK: - private
    
    private var isCurrentUserHost: Bool {
        let hostIds = self.audioRoom.hosts.map { $0.id }
        let isCurrentUserHost = hostIds.contains(streamVideo.user.id)
        return isCurrentUserHost
    }
    
    private func checkAudioSettings() {
        hasPermissionsToSpeak = isCurrentUserHost
        isUserMuted = !isCurrentUserHost
        callViewModel.callSettings = CallSettings(audioOn: isCurrentUserHost, videoOn: false)
    }
    
    private func subscribeForParticipantChanges() {
        callViewModel.$callParticipants.sink { [weak self] participants in
            guard let self = self else { return }
            self.update(participants: participants)
        }
        .store(in: &cancellables)
    }
    
    private func update(participants: [String: CallParticipant]) {
        var hostIds = self.audioRoom.hosts.map { $0.id }
        self.hosts = participants.filter { (key, participant) in
            hostIds.contains(participant.userId)
        }
        .map { $0.value }
        .sorted(by: { $0.name < $1.name })
        
        for (userId, capabilities) in activeCallPermissions {
            if capabilities.contains("send-audio"),
                let participant = findUser(with: userId, in: participants) {
                hosts.append(participant)
                hostIds.append(userId)
            }
        }
        
        self.otherUsers = participants.filter { (key, participant) in
            !hostIds.contains(participant.userId)
        }
        .map { $0.value }
        .sorted(by: { $0.name < $1.name })
    }
    
    private func findUser(
        with userId: String,
        in participants: [String: CallParticipant]
    ) -> CallParticipant? {
        for (_, participant) in participants {
            if participant.userId == userId {
                return participant
            }
        }
        return nil
    }
    
    private func subscribeForAudioChanges() {
        callViewModel.$callSettings.sink { [weak self] callSettings in
            guard let self = self else { return }
            self.isUserMuted = !callSettings.audioOn
        }
        .store(in: &cancellables)
    }
    
    private func subscribeForCallStateChanges() {
        callViewModel.$callingState.sink { [weak self] callState in
            guard let self = self else { return }
            self.loading = callState != .inCall
            if callState == .inCall {
                self.isCallLive = self.callViewModel.call?.state?.backstage == false
                self.subscribeForCallUpdates()
                self.subscribeForPermissionsRequests()
                self.subscribeForPermissionUpdates()
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeForPermissionsRequests() {
        Task {
            for await request in try call.permissionRequests() {
                self.permissionRequest = request
            }
        }
    }
    
    private func subscribeForPermissionUpdates() {
        Task {
            for await update in try call.permissionUpdates() {
                let userId = update.user.id
                self.activeCallPermissions[userId] = update.ownCapabilities
                if userId == streamVideo.user.id
                    && !update.ownCapabilities.contains("send-audio")
                    && callViewModel.callSettings.audioOn {
                    changeMuteState()
                }
                self.update(participants: callViewModel.callParticipants)
            }
        }
    }
    
    private func subscribeForCallUpdates() {
        guard let currentCall = callViewModel.call else { return }
        callViewModel.call?.$state.sink { call in
            DispatchQueue.main.async {
                if call == nil { return }
                self.isCallLive = call?.backstage == false
                if !self.isCallLive && !currentCall.currentUserHasCapability(.updateCall) {
                    self.leaveCall()
                    self.callEnded = true
                }
            }
        }
        .store(in: &cancellables)
    }
    
}
