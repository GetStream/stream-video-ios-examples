//
//  IconView.swift
//  AudioRooms
//
//  Created by Stefan Blos on 08.02.23.
//

import SwiftUI

struct IconView: View {
    
    let imageName: String
    
    var body: some View {
        Image(systemName: imageName)
            .foregroundColor(.primary)
            .padding(8)
            .background(Color.backgroundColor, in: Circle())
    }
    
}

struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        IconView(imageName: "plus")
    }
}
