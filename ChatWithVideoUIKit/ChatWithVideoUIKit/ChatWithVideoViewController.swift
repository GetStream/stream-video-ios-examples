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
import StreamVideoUIKit

class ChatWithVideoViewController: ChatChannelVC {
    
    var cancellables = Set<AnyCancellable>()
    
    var callViewModel: CallViewModel!
    var callView: UIView?
    
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
                extraData: [:]
            )
        } ?? []
        callViewModel.startCall(
            callId: UUID().uuidString,
            participants: participants
        )
        let next = CallViewController.make(with: self.callViewModel)
        self.callView = next.view
        self.view.embed(self.callView!)
    }
    
    private func listenToIncomingCalls() {
        callViewModel.$callingState.sink { [weak self] newState in
            guard let self = self else { return }
            if case .incoming(_) = newState, self == self.navigationController?.topViewController {
                let next = CallViewController.make(with: self.callViewModel)
                self.callView = next.view
                self.self.view.embed(self.callView!)
            } else if newState == .idle {
                self.callView?.removeFromSuperview()
                self.callView = nil
            }
        }
        .store(in: &cancellables)
    }
    
}
