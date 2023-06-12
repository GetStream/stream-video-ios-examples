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
    @Published public private(set) var call: Call? {
        didSet { didUpdateCall(call) }
    }

    /// Tracks the current state of a call. It should be used to show different UI in your views.
    @Published public var callingState: CallingState = .idle

    /// Provides information about the current call settings, such as the camera position and whether there's an audio and video turned on.
    @Published public var callSettings = CallSettings()

    /// Contains info about a participant event. It's reset to nil after 2 seconds.
    @Published public var participantEvent: ParticipantEvent?

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

    private let audioRoom: AudioRoom
    private var cancellables = Set<AnyCancellable>()
    private let callType: String = .audioRoom
    private var enteringCallTask: Task<Void, Never>?
    private var currentEventsTask: Task<Void, Never>?

    init(audioRoom: AudioRoom) {
        self.audioRoom = audioRoom
        checkAudioSettings()

        callingState = .joining
        enterCall(
            callId: audioRoom.callId,
            callType: callType,
            members: audioRoom.hosts.map(\.member)
        )
        subscribeForParticipantChanges()
        subscribeForAudioChanges()
        subscribeForCallStateChanges()
    }

    func leaveCall() {
        if callingState == .outgoing {
            Task {
                try? await call?.reject()
                cleanUpAfterLeavingCall()
            }
        } else {
            cleanUpAfterLeavingCall()
        }
    }

    func endCall() {
        Task {
            try await call?.end()
        }
    }

    func raiseHand() {
        Task {
            try await call?.request(permissions: [.sendAudio])
        }
    }

    func grantUserPermissions() {
        guard let permissionRequest else { return }
        Task {
            try await call?.grant(
                permissions: permissionRequest.permissions.compactMap { Permission(rawValue: $0) },
                for: permissionRequest.user.id
            )
        }
    }

    func revokePermissions() {
        guard let revokingParticipant else { return }
        Task {
            try await call?.revoke(
                permissions: [.sendAudio],
                for: revokingParticipant.userId
            )
        }
    }

    func canAskForAudioPermission() -> Bool {
        guard let call = call else { return false }
        return call.currentUserCanRequestPermissions([.sendAudio])
    }

    func changeMuteState() {
        guard let call = call else { return }
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

    func goLive() {
        Task {
            try await call?.goLive()
        }
    }

    func stopLive() {
        Task {
            try await call?.stopLive()
        }
    }

    var showGoLiveButton: Bool {
        guard let call = call else { return false }
        return call.currentUserHasCapability(.updateCall) && !isCallLive
    }

    var showStopLiveButton: Bool {
        guard let call = call else { return false }
        return call.currentUserHasCapability(.updateCall) && isCallLive
    }

    var showEndCallButton: Bool {
        guard let call = call else { return false }
        return call.currentUserHasCapability(.endCall)
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

    private func enterCall(
        call: Call? = nil,
        callId: String,
        callType: String,
        members: [Member]
    ) {
        if enteringCallTask != nil || callingState == .inCall {
            return
        }
        enteringCallTask = Task {
            do {
                log.debug("Starting call")
                let call = call ?? streamVideo.call(callType: callType, callId: callId, members: members)
                try await call.join(ring: false, callSettings: callSettings)
                save(call: call)
                enteringCallTask = nil
            } catch {
                log.error("Error starting a call \(error.localizedDescription)")
//                self.error = error
                callingState = .idle
                enteringCallTask = nil
            }
        }
    }

    private func save(call: Call) {
        guard enteringCallTask != nil else {
            call.leave()
            self.call = nil
            return
        }
        self.call = call
        updateCallStateIfNeeded()
        listenForParticipantEvents()
        log.debug("Started call")
    }

    private func updateCallStateIfNeeded() {
        if callingState == .outgoing {
            if (call?.state.participantCount ?? 0) > 0 {
                callingState = .inCall
            }
            return
        }
        guard call != nil || call?.state.participants.isEmpty == false else { return }
        if callingState != .reconnecting {
            callingState = .inCall
        } else {
            let shouldGoInCall = (call?.state.participantCount ?? 0) > 1
            if shouldGoInCall {
                callingState = .inCall
            }
        }
    }

    private func listenForParticipantEvents() {
        guard let call = call else {
            return
        }
        currentEventsTask = Task {
            for await event in call.participantEvents() {
                self.participantEvent = event
                if
                    event.action == .leave,
                    call.state.participantCount == 1,
                    call.state.callData?.session?.acceptedBy.isEmpty == false {
                    leaveCall()
                } else {
                    // The event is shown for 2 seconds.
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                }
                self.participantEvent = nil
            }
        }
    }

    private func cleanUpAfterLeavingCall() {
        log.debug("Leaving call")
        enteringCallTask?.cancel()
        enteringCallTask = nil
        cancellables.forEach { $0.cancel() }
        call?.leave()
        call = nil
        hosts = []
        otherUsers = []
        currentEventsTask?.cancel()
        callingState = .idle
    }

    // MARK: - Subscribers

    private func subscribeForParticipantChanges() {
        call?
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

    private func subscribeForCallStateChanges() {
        $callingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.didReceiveCallStateUpdates($0) }
            .store(in: &cancellables)
    }

    private func subscribeForPermissionsRequests() {
        Task {
            guard let call = call else { return }
            for await request in call.permissionRequests() {
                DispatchQueue.main.async {
                    self.permissionRequest = request
                }
            }
        }
    }

    private func subscribeForPermissionUpdates() {
        Task {
            guard let call = call else { return }
            for await update in call.permissionUpdates() {
                DispatchQueue.main.async { [weak self] in
                    self?.didReceivePermissionUpdate(update)
                }
            }
        }
    }

    private func subscribeForCallUpdates() {
        call?
            .state
            .$callData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.didReceiveCallUpdates($0) }
            .store(in: &cancellables)
    }

    private func subscribeForReconnectionUpdates() {
        call?
            .state
            .$reconnectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.didReceiveReconnectionUpdate($0) }
            .store(in: &cancellables)
    }

    // MARK: - Subscription Handlers

    private func didReceiveCallUpdates(_ callData: CallData?) {

        guard let callData = callData, let currentCall = call else {
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
            isCallLive = call?.state.callData?.backstage == false
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

        didReceiveParticipantUpdates(call?.state.participants ?? [:])
    }

    private func didReceiveReconnectionUpdate(
        _ reconnectionStatus: ReconnectionStatus
    ) {
        if reconnectionStatus == .reconnecting {
            if callingState != .reconnecting {
                callingState = .reconnecting
            }
        } else if reconnectionStatus == .disconnected {
            leaveCall()
        } else {
            if callingState != .inCall, callingState != .outgoing {
                callingState = .inCall
            }
        }
    }

    private func didUpdateCall(_ call: Call?) {
        subscribeForParticipantChanges()
        subscribeForCallUpdates()
        subscribeForReconnectionUpdates()
    }
}

