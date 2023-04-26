//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct StageView: View {
    
    @StateObject var viewModel: CallViewModel
    
    @ObservedObject var appState = AppState.shared
    
    init(callId: String? = nil) {
        _viewModel = StateObject(wrappedValue: CallViewModel())
        if let callId = callId, viewModel.callingState == .idle {
            viewModel.joinCall(callId: callId, type: .default)
        }
    }
        
    var body: some View {
        HomeView(viewModel: viewModel)
            .modifier(
                CallModifier(
                    viewFactory: VideoWithChatViewFactory.shared, viewModel: viewModel
                )
            )
    }
}
