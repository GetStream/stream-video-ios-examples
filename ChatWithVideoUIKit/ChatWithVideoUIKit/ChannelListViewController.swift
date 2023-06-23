//
//  ViewController.swift
//  ChatWithVideoUIKit
//
//  Created by Martin Mitrevski on 22.11.22.
//

import UIKit

import StreamChat
import StreamChatUI
import UIKit
import class StreamVideoSwiftUI.CallViewModel
import Combine
import StreamVideoUIKit

class ChannelListViewController: ChatChannelListVC {
    
    let callViewModel = CallViewModel()
    
    private var cancellables = Set<AnyCancellable>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        listenToIncomingCalls()
    }

    override func didTapOnCurrentUserAvatar(_ sender: Any) {
        
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
