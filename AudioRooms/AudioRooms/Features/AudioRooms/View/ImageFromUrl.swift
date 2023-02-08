//
//  ImageFromUrl.swift
//  AudioRooms
//
//  Created by Stefan Blos on 08.02.23.
//

import SwiftUI

struct ImageFromUrl: View {
    
    var url: URL
    var size: CGFloat
    var offset: CGFloat?
    
    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable()
                .frame(width: size, height: size)
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .offset(x: offset ?? 0, y: offset ?? 0)
        } placeholder: {
            ProgressView()
                .frame(width: size, height: size)
                .offset(x: offset ?? 0, y: offset ?? 0)
        }
    }
}

struct ImageFromUrl_Previews: PreviewProvider {
    static var previews: some View {
        ImageFromUrl(
            url: URL(string: "https://getstream.io/static/237f45f28690696ad8fff92726f45106/c59de/thierry.webp")!,
            size: 40
        )
    }
}
