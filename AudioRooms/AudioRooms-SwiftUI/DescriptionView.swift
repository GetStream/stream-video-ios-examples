//
//  DescriptionView.swift
//  AudioRooms
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import SwiftUI
import StreamVideo

struct DescriptionView: View {
    var title: String?
    var description: String?
    var participants: [CallParticipant]

    var body: some View {
        VStack {
            VStack {
                Text("\(title ?? "")")
                  .font(.title)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .lineLimit(1)
                  .padding([.bottom], 8)

                Text("\(description ?? "")")
                  .font(.body)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .lineLimit(1)
                  .padding([.bottom], 4)

                Text("\(participants.count) participants")
                  .font(.caption)
                  .frame(maxWidth: .infinity, alignment: .leading)
            }.padding([.leading, .trailing])
        }
    }
}
