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
                            viewModel.selectedMeeting = meeting
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
            .overlay(
                viewModel.selectedMeeting != nil ? PreJoiningView(
                    callViewModel: callViewModel,
                    meeting: $viewModel.selectedMeeting
                ) : nil
            )
            .modifier(CallModifier(viewModel: callViewModel))
            .navigationTitle("Meetings")
            .navigationBarHidden(
                viewModel.selectedMeeting != nil || callViewModel.callingState != .idle
            )
        }
    }
}
