//
//  CustomCallKitService.swift
//  RingingFlow
//
//  Created by Ilias Pavlidakis on 9/5/24.
//

import Foundation
import StreamVideo
import Combine

final class CustomCallKitService: CallKitService {

    private var ringingCallObservationCancellable: AnyCancellable?
    private var shouldReportIncomingCall: Bool {
        Configuration.allowCallRingingWhileInCall || (!Configuration.allowCallRingingWhileInCall && streamVideo?.state.activeCall == nil)
    }

    override func didUpdate(_ streamVideo: StreamVideo?) {
        super.didUpdate(streamVideo)
        ringingCallObservationCancellable?.cancel()

        guard let streamVideo else {
            return
        }

        ringingCallObservationCancellable = streamVideo
            .state
            .$ringingCall
            .removeDuplicates { $0?.cId == $1?.cId }
            .sink { ringingCall in
                Task { @MainActor [weak self] in
                    self?.didUpdateRingingCall(ringingCall)
                }
            }
    }

    override func reportIncomingCall(
        _ cid: String,
        localizedCallerName: String,
        callerId: String,
        hasVideo: Bool = false,
        completion: @escaping ((any Error)?) -> Void
    ) {
        Task { @MainActor in
            execute(
                cid,
                localizedCallerName: localizedCallerName,
                callerId: callerId,
                completion: completion
            )
        }
    }

    // MARK: - Private helpers

    @MainActor
    private func didUpdateRingingCall(_ ringingCall: Call?) {
        guard let streamVideo else {
            return
        }
        guard 
            let ringingCall,
            ringingCall.state.createdBy?.id != streamVideo.user.id
        else {
            return
        }

        guard shouldReportIncomingCall else {
            Task {
                do {
                    try await ringingCall.sendCustomEvent([
                        CustomEvent.isBusy.rawValue: .bool(true)
                    ])
                    log.debug("\(streamVideo.user.id) isBusy in call:\(ringingCall.cId)")
                    try await ringingCall.reject()
                    log.debug("\(streamVideo.user.id) rejected call:\(ringingCall.cId)")
                } catch {
                    log.error(error)
                }
            }
            return
        }

        Task {
            do {
                try await ringingCall.sendCustomEvent([
                    CustomEvent.isAlive.rawValue: .bool(true)
                ])
                log.debug("\(streamVideo.user.id) isAlive in call:\(ringingCall.cId)")
            } catch {
                log.error(error)
            }
        }
    }

    @MainActor
    private func execute(
        _ cid: String,
        localizedCallerName: String,
        callerId: String,
        completion: @escaping ((any Error)?) -> Void
    ) {
        if shouldReportIncomingCall {
            super.reportIncomingCall(
                cid,
                localizedCallerName: localizedCallerName,
                callerId: callerId,
                completion: completion
            )
        } else {
            callProvider.reportCall(
                with: .init(),
                endedAt: .distantPast,
                reason: .declinedElsewhere
            )
            completion(nil)
        }
    }
}
