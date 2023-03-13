//
//  CallControlsView.swift
//  UICookbook
//
//  Created by Martin Mitrevski on 13.3.23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct CustomCallControlsView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        HStack(spacing: 32) {
            VideoIconView(viewModel: viewModel)
            MicrophoneIconView(viewModel: viewModel)
            ToggleCameraIconView(viewModel: viewModel)
            HangUpIconView(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 85)
    }
}
