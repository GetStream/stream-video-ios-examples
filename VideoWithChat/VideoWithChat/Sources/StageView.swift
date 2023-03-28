//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct StageView: View {
    
    @StateObject var viewModel: CallViewModel
    
    @ObservedObject var appState: AppState
    
    init(appState: AppState, callId: String? = nil) {
        _viewModel = StateObject(wrappedValue: CallViewModel())
        _appState = ObservedObject(wrappedValue: appState)
        if let callId = callId, viewModel.callingState == .idle {
            viewModel.joinCall(callId: callId, type: "default")
        }
    }
        
    var body: some View {
        HomeView(viewModel: viewModel, appState: appState)
            .modifier(CallModifier(viewFactory: VideoWithChatViewFactory.shared, viewModel: viewModel))
            .onReceive(appState.$activeCallController) { callController in
                if let callController = callController {
                    viewModel.setCallController(callController)
                    appState.activeCallController = nil
                }
            }
            .onAppear {
                viewModel.videoOptions = VideoOptions(preferredDimensions: .half)
            }
    }
}
