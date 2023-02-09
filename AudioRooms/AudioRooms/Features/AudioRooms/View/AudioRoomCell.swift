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
            VStack(alignment: .leading) {
                Text(audioRoom.title)
                    .font(.headline)

                Text(audioRoom.subtitle)
                    .font(.caption)
                
                HStack(spacing: 30) {
                    if audioRoom.hosts.count > 1 {
                        ZStack {
                            ImageFromUrl(
                                url: audioRoom.hosts[0].imageURL,
                                size: 40,
                                offset: -imageOffset
                            )
                            
                            ImageFromUrl(
                                url: audioRoom.hosts[1].imageURL,
                                size: 40,
                                offset: imageOffset
                            )
                        }
                        .frame(height: 80)
                        .padding(.leading, imageOffset)
                    }
                    
                    VStack(alignment: .leading, spacing: imageOffset / 2) {
                        ForEach(audioRoom.hosts) { host in
                            Text(host.name)
                                .font(.headline)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
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
