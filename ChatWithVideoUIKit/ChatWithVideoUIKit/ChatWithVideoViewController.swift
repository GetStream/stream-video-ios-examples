//
//  ChatWithVideoViewController.swift
//  ChatWithVideoUIKit
//
//  Created by Martin Mitrevski on 22.11.22.
//

import Combine
import UIKit
import StreamChatUI
import StreamVideo
import class StreamVideoSwiftUI.CallViewModel
import StreamVideoUIKit

class ChatWithVideoViewController: ChatChannelVC {
    
    var cancellables = Set<AnyCancellable>()
    
    var callViewModel: CallViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "phone.fill"),
            style: .done,
            target: self,
            action: #selector(startCall)
        )
        listenToIncomingCalls()
    }
    
    @objc func startCall() {
        let participants = channelController.channel?.lastActiveMembers.map { member in
            User(
                id: member.id,
                name: member.name,
                imageURL: member.imageURL,
                customData: [:]
            )
        } ?? []
        callViewModel.startCall(
            callType: .default,
            callId: UUID().uuidString,
            members: participants.map { .init(custom: $0.customData, role: $0.role, userId: $0.id) }
        )

        let next = CallViewController.make(with: self.callViewModel)
        CallViewHelper.shared.add(callView: next.view)
    }
    
    private func listenToIncomingCalls() {
        callViewModel.$callingState.sink { [weak self] newState in
            guard let self = self else { return }
            if case .incoming(_) = newState, self == self.navigationController?.topViewController {
                let next = CallViewController.make(with: self.callViewModel)
                CallViewHelper.shared.add(callView: next.view)
            } else if newState == .idle {
                CallViewHelper.shared.removeCallView()
            }
        }
        .store(in: &cancellables)
    }
    
}
