//
//  AudioRoomCell.swift
//  AudioRooms
//
//  Created by Stefan Blos on 08.02.23.
//

import SwiftUI

import SwiftUI
import StreamVideo
import NukeUI

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
                            LazyImage(url: audioRoom.hosts[0].imageURL)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .offset(x: -imageOffset, y: -imageOffset)
                            LazyImage(url: audioRoom.hosts[1].imageURL)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .offset(x: imageOffset, y: imageOffset)
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
