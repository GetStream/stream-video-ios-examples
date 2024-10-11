//
//  LivestreamHomeViewModel.swift
//  LivestreamingSample
//
//  Created by Martin Mitrevski on 8.5.23.
//

import Foundation
import StreamVideo
import AVKit

@MainActor
class LivestreamHomeViewModel: ObservableObject {
    
    @Injected(\.streamVideo) var streamVideo
    
    @Published var callId = ""
    @Published var watchedCallId: String = ""
    @Published var loading = false
    @Published var call: Call?
    @Published var hlsURL: URL?
    @Published var logoutAlertShown = false
    private var callsController: CallsController? {
        didSet {
            subscribeForBroadcastEvents()
        }
    }
    @Published var watchedCall: Call?
    
    private var broadcastEventsTask: Task<Void, Never>?
    
    func createLivestream() {
        guard !callId.isEmpty else { return }
        let call = streamVideo.call(callType: .default, callId: callId)
        Task {
            do {
                loading = true
                try await call.join(create: true)
                loading = false
                self.call = call
            } catch {
                loading = false
            }
        }
    }

    func fetchAnonymousUserTokenIfRequired(for callId: String) async throws {
        if AppState.shared.currentUser == .anonymous {
            let token = try await TokenService.shared.fetchToken(for: User.anonymous.id, callIds: ["default:\(callId)"])
            AppState.shared.streamWrapper = StreamWrapper(
                apiKey: "hd8szvscpxvd",
                userCredentials: .init(user: .anonymous, tokenValue: token.rawValue),
                tokenProvider: { _ in }
            )
        }
    }

    func watchCall() {
        guard !watchedCallId.isEmpty else { return }
        Task {
            try await fetchAnonymousUserTokenIfRequired(for: watchedCallId)
            self.callsController = makeCallsController()
            try await callsController?.loadNextCalls()
            if let firstCall = callsController?.calls.first {
                watchedCall = firstCall
                watchedCallId = firstCall.cId
                hlsURL = URL(string: firstCall.state.egress?.hls?.playlistUrl ?? "")
            }
        }
    }
    
    private func makeCallsController() -> CallsController {
        let sortParam = CallSortParam(direction: .descending, field: .createdAt)
        let filters: [String: RawJSON] = ["id": .dictionary(["$eq": .string(watchedCallId)])]
        let callsQuery = CallsQuery(sortParams: [sortParam], filters: filters, watch: AppState.shared.currentUser != User.anonymous)
        return streamVideo.makeCallsController(callsQuery: callsQuery)
    }
    
    private func subscribeForBroadcastEvents() {
        broadcastEventsTask?.cancel()
        broadcastEventsTask = Task {
            for await videoEvent in streamVideo.subscribe() {
                switch videoEvent {
                case .typeCallHLSBroadcastingStartedEvent(let event) where event.callCid == watchedCallId:
                    let url = event.hlsPlaylistUrl.replacingOccurrences(of: "\\u0026", with: "&")
                    self.hlsURL = URL(string: url)
                case .typeCallHLSBroadcastingStoppedEvent:
                    self.hlsURL = nil
                default:
                    break
                }
            }
        }
    }
    
}
