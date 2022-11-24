//
//  ChannelListRouter.swift
//  ChatWithVideoUIKit
//
//  Created by Martin Mitrevski on 22.11.22.
//

import Foundation
import UIKit
import StreamChat
import StreamChatUI

class ChannelListRouter: ChatChannelListRouter {
    
    let modalTransitioningDelegate = StreamModalTransitioningDelegate()
    
    override func showChannel(for cid: ChannelId) {
        let vc = components.channelVC.init()
        vc.channelController = rootViewController.controller.client.channelController(
            for: cid,
            channelListQuery: rootViewController.controller.query
        )
        if let vc = vc as? ChatWithVideoViewController,
            let rootVC = rootViewController as? ChannelListViewController {
            vc.callViewModel = rootVC.callViewModel
        }
        
        if let splitVC = rootViewController.splitViewController {
            splitVC.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        } else if let navigationVC = rootViewController.navigationController {
            navigationVC.show(vc, sender: self)
        } else {
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.transitioningDelegate = modalTransitioningDelegate
            navigationVC.modalPresentationStyle = .custom
            rootViewController.show(navigationVC, sender: self)
        }
    }
    
}
