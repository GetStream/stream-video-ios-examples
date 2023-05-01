//
//  HomeView.swift
//  UICookbook
//
//  Created by Martin Mitrevski on 13.3.23.
//

import SwiftUI
import StreamVideo

struct HomeView: View {
    
    @ObservedObject var appState: AppState
    
    @StateObject var viewModel = CallViewModel()
        
    var body: some View {
        ZStack {
            JoinCallView(viewModel: viewModel)
            
            if viewModel.callingState == .joining {
                ProgressView()
            } else if viewModel.callingState == .inCall {
                CallView(viewModel: viewModel)
            }
        }
    }
}

struct JoinCallView: View {
    
    @State var callId = ""
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        VStack {
            TextField("Insert call id", text: $callId)
            Button {
                resignFirstResponder()
                viewModel.startCall(callId: callId, type: "default", members: [])
            } label: {
                Text("Join call")
            }
            Spacer()
        }
        .padding()
    }
    
}

public func resignFirstResponder() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}
