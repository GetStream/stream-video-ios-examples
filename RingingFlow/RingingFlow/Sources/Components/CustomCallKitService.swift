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

        guard streamVideo.state.activeCall == nil else {
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
}
