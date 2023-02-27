//
//  MeetingsView.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 18.1.23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct MeetingsView: View {
    
    @StateObject var callViewModel = CallViewModel()
    @StateObject var viewModel = MeetingViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.meetings) { meeting in
                        Button {
                            callViewModel.enterLobby(callId: meeting.id, participants: meeting.participants)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(meeting.name)
                                        .font(.headline)
                                    Text(meeting.timeDisplay)
                                        .font(.caption)
                                }
                                Spacer()
                                Text("\(meeting.participants.count) participants")
                                    .font(.subheadline)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .foregroundColor(.primary)
                        }
                        
                        Divider()
                    }
                }
            }
            .modifier(CallModifier(viewFactory: MeetingViewFactory.shared, viewModel: callViewModel))
            .navigationTitle("Meetings")
            .navigationBarHidden(
                viewModel.selectedMeeting != nil || callViewModel.callingState != .idle
            )
        }
    }
}
