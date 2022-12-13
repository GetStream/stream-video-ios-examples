//
//  CallChatViewController.swift
//  VideoWithChatUIKit
//
//  Created by Martin Mitrevski on 13.12.22.
//

import UIKit
import StreamVideo
import StreamVideoSwiftUI
import StreamVideoUIKit
import SwiftUI

class CallChatViewController: CallViewController {
    
    public static func makeCallChatController(
        with viewModel: CallViewModel? = nil
    ) -> CallChatViewController {
        let controller = CallChatViewController()
        controller.viewModel = viewModel ?? CallViewModel()
        return controller
    }
    
    override func setupVideoView() {
        let videoView = makeVideoView(with: VideoWithChatViewFactory.shared)
        view.embed(videoView)
    }

}

class VideoWithChatViewFactory: ViewFactory {
    
    static let shared = VideoWithChatViewFactory()
    
    private init() {}
    
    func makeCallControlsView(viewModel: CallViewModel) -> some View {
        ChatCallControls(viewModel: viewModel)
    }
    
}
