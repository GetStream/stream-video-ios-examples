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
            
            if viewModel.callingState == .outgoing {
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
                viewModel.startCall(callId: callId, participants: [])
            } label: {
                Text("Join call")
            }
            Spacer()
        }
        .padding()
    }
    
}
