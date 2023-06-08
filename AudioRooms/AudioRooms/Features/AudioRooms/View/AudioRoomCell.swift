//
//  AudioRoomCell.swift
//  AudioRooms
//
//  Created by Stefan Blos on 08.02.23.
//

import SwiftUI
import StreamVideo

struct AudioRoomCell: View {
    
    let audioRoom: AudioRoom
    
    let imageOffset: CGFloat = 10
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack {
                    Text(audioRoom.title)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(audioRoom.subtitle)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack(spacing: 16) {
                    ZStack {
                        ForEach(Array(audioRoom.hosts.enumerated()), id: \.offset) { (index, host) in
                            ImageFromUrl(
                                url: host.imageURL,
                                size: 40,
                                offset: -imageOffset * CGFloat(index)
                            )
                        }
                    }
                    .frame(height: 40)
                    
                    VStack(alignment: .leading) {
                        ForEach(audioRoom.hosts) { host in
                            Text(host.name)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.primary)
        .background(Color.backgroundColor)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct AudioRoomCell_Previews: PreviewProvider {
    static var previews: some View {
        AudioRoomCell(audioRoom: .preview)
    }
}
