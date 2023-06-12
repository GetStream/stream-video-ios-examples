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

    /// Provides access to the current call.
    private var call: Call!

    /// Provides information about the current call settings, such as the camera position and whether there's an audio and video turned on.
    @Published private var callSettings = CallSettings()

    @Published var hosts = [CallParticipant]()
    @Published var otherUsers = [CallParticipant]()
    @Published var hasPermissionsToSpeak = false
    @Published var isUserMuted = true
    @Published var loading = true
    @Published var permissionPopupShown = false
    @Published var revokePermissionPopupShown = false
    @Published var activeCallPermissions = [String: [String]]() {
        didSet {
            hasPermissionsToSpeak = activeCallPermissions[streamVideo.user.id]?.contains("send-audio") == true || isCurrentUserHost
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

    var showEndCallButton: Bool { call.currentUserHasCapability(.endCall) }

    private let audioRoom: AudioRoom
    private var cancellables = Set<AnyCancellable>()
    private let callType: String = .audioRoom

    init(audioRoom: AudioRoom) {
        self.audioRoom = audioRoom
        self.call = streamVideo.call(
            callType: callType,
            callId: audioRoom.callId,
            members: audioRoom.hosts.map(\.member)
        )

        subscribeForParticipantChanges()
        subscribeForCallUpdates()
        subscribeForParticipantChanges()
        subscribeForAudioChanges()

        checkAudioSettings()
        joinRoom(audioRoom)
    }

    func leaveCall() {
        cleanUpAfterLeavingCall()
    }

    func endCall() {
        Task {
            try await call.end()
        }
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
                permissions: permissionRequest
                    .permissions
                    .compactMap { Permission(rawValue: $0) },
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
        return call.currentUserCanRequestPermissions([.sendAudio])
    }

    func changeMuteState() {
        Task {
            do {
                let isEnabled = !callSettings.audioOn
                try await call.changeAudioState(isEnabled: isEnabled)
                callSettings = CallSettings(
                    audioOn: isEnabled,
                    videoOn: callSettings.videoOn,
                    speakerOn: callSettings.speakerOn,
                    audioOutputOn: callSettings.audioOutputOn
                )
            } catch {
                log.error("Error toggling microphone")
            }
        }
    }

    func toggleLive() {
        Task {
            if isCallLive {
                try await call.stopLive()
            } else {
                try await call.goLive()
            }
        }
    }

    //MARK: - Private Helpers
    
    private var isCurrentUserHost: Bool {
        Set(hosts.map(\.userId)).contains(streamVideo.user.id)
    }

    private func checkAudioSettings() {
        hasPermissionsToSpeak = isCurrentUserHost
        isUserMuted = !isCurrentUserHost
        callSettings = CallSettings(audioOn: isCurrentUserHost, videoOn: false)
    }

    private func joinRoom(_ audioRoom: AudioRoom) {
        loading = true
        Task {
            do {
                log.debug("Joining room \(audioRoom.callId)")
                try await call.join(ring: false, callSettings: callSettings)
                loading = false
                isCallLive = call.state.callData?.backstage == false
                subscribeForPermissionsRequests()
                subscribeForPermissionUpdates()
                log.debug("Joined room \(audioRoom.callId)")
            } catch {
                log.error("Error joining room \(audioRoom.callId) \(error.localizedDescription)")
            }
        }
    }

    private func save(call: Call) {

    }

    private func cleanUpAfterLeavingCall() {
        log.debug("Leaving call")
        cancellables.forEach { $0.cancel() }
        call.leave()
        hosts = []
        otherUsers = []
    }

    // MARK: - Subscribers

    private func subscribeForParticipantChanges() {
        call
            .state
            .$participants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.didReceiveParticipantUpdates($0) }
            .store(in: &cancellables)
    }

    private func subscribeForAudioChanges() {
        $callSettings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] callSettings in self?.isUserMuted = !callSettings.audioOn }
            .store(in: &cancellables)
    }

    private func subscribeForPermissionsRequests() {
        Task {
            for await request in call.permissionRequests() {
                DispatchQueue.main.async {
                    self.permissionRequest = request
                }
            }
        }
    }

    private func subscribeForPermissionUpdates() {
        Task {
            for await update in call.permissionUpdates() {
                DispatchQueue.main.async { [weak self] in
                    self?.didReceivePermissionUpdate(update)
                }
            }
        }
    }

    private func subscribeForCallUpdates() {
        call
            .state
            .$callData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.didReceiveCallUpdates($0) }
            .store(in: &cancellables)
    }

    // MARK: - Subscription Handlers

    private func didReceiveCallUpdates(_ callData: CallData?) {
        guard let callData = callData else {
            isCallLive = false
            return
        }

        isCallLive = callData.backstage == false

        if !isCallLive && !call.currentUserHasCapability(.updateCall) {
            leaveCall()
            callEnded = true
        }
    }

    private func didReceiveParticipantUpdates(
        _ participants: [String: CallParticipant]
    ) {
        var hostIds = Set(self.audioRoom.hosts.map { $0.id })

        for (userId, capabilities) in activeCallPermissions {
            if capabilities.contains("send-audio") {
                hostIds.insert(userId)
            }
        }

        var hosts: [CallParticipant] = []
        var otherUsers: [CallParticipant] = []

        participants.forEach { (_, participant) in
            hostIds.contains(participant.userId)
            ? hosts.append(participant)
            : otherUsers.append(participant)
        }

        self.hosts = hosts.sorted(by: { $0.name < $1.name })
        self.otherUsers = otherUsers.sorted(by: { $0.name < $1.name })

        hasPermissionsToSpeak = isCurrentUserHost
    }

    private func didReceivePermissionUpdate(_ update: PermissionsUpdated) {
        let userId = update.user.id
        activeCallPermissions[userId] = update.ownCapabilities

        if
            userId == streamVideo.user.id,
            !update.ownCapabilities.contains("send-audio"),
            callSettings.audioOn
        {
            changeMuteState()
        }

        didReceiveParticipantUpdates(call.state.participants)
    }
}

