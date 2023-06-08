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
            members: audioRoom.hosts.map(\.member)
        )
        subscribeForParticipantChanges()
        subscribeForAudioChanges()
        subscribeForCallStateChanges()
    }

    func leaveCall() {
        callViewModel.hangUp()
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
//        Task {
//            do {
//                let isEnabled = !callSettings.audioOn
//                try await call.changeAudioState(isEnabled: isEnabled)
//                callSettings = CallSettings(
//                    audioOn: isEnabled,
//                    videoOn: callSettings.videoOn,
//                    speakerOn: callSettings.speakerOn,
//                    audioOutputOn: callSettings.audioOutputOn
//                )
//            } catch {
//                log.error("Error toggling microphone")
//            }
//        }
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

    var showEndCallButton: Bool {
        do {
            return try call.currentUserHasCapability(.endCall)
        } catch {
            return false
        }
    }

    //MARK: - private

    private var isCurrentUserHost: Bool {
        Set(audioRoom.hosts.map(\.id)).contains(streamVideo.user.id)
    }

    private func checkAudioSettings() {
        hasPermissionsToSpeak = isCurrentUserHost
        isUserMuted = !isCurrentUserHost
        callViewModel.callSettings = CallSettings(audioOn: isCurrentUserHost, videoOn: false)
    }

    private func subscribeForParticipantChanges() {
        callViewModel
            .$callParticipants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.didReceiveParticipantUpdates($0) }
            .store(in: &cancellables)
    }

    private func subscribeForAudioChanges() {
        callViewModel
            .$callSettings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] callSettings in self?.isUserMuted = !callSettings.audioOn }
            .store(in: &cancellables)
    }

    private func subscribeForCallStateChanges() {
        callViewModel
            .$callingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.didReceiveCallStateUpdates($0) }
            .store(in: &cancellables)
    }

    private func subscribeForPermissionsRequests() {
        Task {
            for await request in try call.permissionRequests() {
                DispatchQueue.main.async {
                    self.permissionRequest = request
                }
            }
        }
    }

    private func subscribeForPermissionUpdates() {
        Task {
            for await update in try call.permissionUpdates() {
                DispatchQueue.main.async { [weak self] in
                    self?.didReceivePermissionUpdate(update)
                }
            }
        }
    }

    private func subscribeForCallUpdates() {
        callViewModel
            .call?
            .state
            .$callData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.didReceiveCallUpdates($0) }
            .store(in: &cancellables)
    }

    // MARK: - Call Handlers

    // MARK: - Private Subscription Handlers

    private func didReceiveCallUpdates(_ callData: CallData?) {
        guard let callData = callData, let currentCall = callViewModel.call else {
            isCallLive = false
            return
        }
        isCallLive = callData.backstage == false
        if !isCallLive && !currentCall.currentUserHasCapability(.updateCall) {
            leaveCall()
            callEnded = true
        }
    }

    private func didReceiveCallStateUpdates(_ callState: CallingState) {
        if callState == .inCall {
            loading = false
            isCallLive = callViewModel.call?.state.callData?.backstage == false
            subscribeForCallUpdates()
            subscribeForPermissionsRequests()
            subscribeForPermissionUpdates()
        } else {
            loading = true
        }
    }

    private func didReceiveParticipantUpdates(
        _ participants: [String: CallParticipant]
    ) {
        var hostsDictionary: [String: CallParticipant] = [:]
        var hostIds = Set(self.audioRoom.hosts.map { $0.id })

        for (userId, capabilities) in activeCallPermissions {
            if capabilities.contains("send-audio") {
                hostIds.insert(userId)
            }
        }

        participants.forEach { (key, participant) in
            guard
                hostIds.contains(participant.userId),
                hostsDictionary[participant.userId] == nil
            else {
                return
            }
            hostsDictionary[participant.userId] = participant
        }

        self.hosts = hostsDictionary
            .values
            .sorted(by: { $0.name < $1.name })

        self.otherUsers = participants
            .filter { (key, participant) in !hostIds.contains(participant.userId) }
            .map { $0.value }
            .sorted(by: { $0.name < $1.name })
    }

    private func didReceivePermissionUpdate(_ update: PermissionsUpdated) {
        let userId = update.user.id
        activeCallPermissions[userId] = update.ownCapabilities
        if
            userId == streamVideo.user.id,
            !update.ownCapabilities.contains("send-audio"),
            callViewModel.callSettings.audioOn
        {
            changeMuteState()
        }

        didReceiveParticipantUpdates(callViewModel.callParticipants)
    }
}

