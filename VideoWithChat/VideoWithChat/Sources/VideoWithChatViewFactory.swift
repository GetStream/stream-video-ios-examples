//
//  VideoWithChatViewFactory.swift
//  VideoWithChat
//
//  Created by Martin Mitrevski on 14.11.22.
//

import StreamVideo
import StreamVideoSwiftUI
import SwiftUI

class VideoWithChatViewFactory: ViewFactory {
    
    static let shared = VideoWithChatViewFactory()
    
    private init() {}
    
    func makeCallControlsView(viewModel: CallViewModel) -> some View {
        ChatCallControls(viewModel: viewModel)
    }
    
}
