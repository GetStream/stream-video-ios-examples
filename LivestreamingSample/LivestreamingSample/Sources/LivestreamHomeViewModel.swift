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
    @Published var watchedCall: CallData?
    
    private var broadcastEventsTask: Task<Void, Never>?
    
    func createLivestream() {
        guard !callId.isEmpty else { return }
        let currentUser = streamVideo.user
        let call = streamVideo.makeCall(callType: .default, callId: callId, members: [currentUser])
        Task {
            do {
                loading = true
                try await call.join()
                loading = false
                self.call = call
            } catch {
                loading = false
            }
        }
    }
    
    func watchCall() {
        guard !watchedCallId.isEmpty else { return }
        callsController = makeCallsController()
        Task {
            try await callsController?.loadNextCalls()
            watchedCall = callsController?.calls.first
            hlsURL = URL(string: watchedCall?.hlsPlaylistUrl ?? "")
        }
    }
    
    private func makeCallsController() -> CallsController {
        let sortParam = CallSortParam(direction: .descending, field: .createdAt)
        let filters: [String: RawJSON] = ["id": .dictionary(["$eq": .string(watchedCallId)])]
        let callsQuery = CallsQuery(sortParams: [sortParam], filters: filters, watch: true)
        return streamVideo.makeCallsController(callsQuery: callsQuery)
    }
    
    private func subscribeForBroadcastEvents() {
        broadcastEventsTask?.cancel()
        guard let callsController else { return }
        broadcastEventsTask = Task {
            for await event in callsController.broadcastEvents() {
                if let event = event as? BroadcastingStartedEvent {
                    let url = event.hlsPlaylistUrl.replacingOccurrences(of: "\\u0026", with: "&")
                    self.hlsURL = URL(string: url)
                } else if event is BroadcastingStoppedEvent {
                    self.hlsURL = nil
                }
            }
        }
    }
    
}
