//
//  UserSelectionView.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 6.8.24.
//

import SwiftUI
import StreamChat

struct UserSelectionView: View {
    
    @State var livestreamId = ""
    @State var selectedUserId: String? {
        didSet {
            if let selectedUserId {
                AppState.shared.connect(userId: selectedUserId)
            }
        }
    }
        
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if selectedUserId == nil {
                    Text("Select user")
                        .font(.title)
                    
                    Button {
                        selectedUserId = "Han_Solo"
                    } label: {
                        Text("Han_Solo")
                            .padding()
                            .background(selectedUserId == "Han_Solo" ? Color.blue : .clear)
                            .cornerRadius(16)
                    }
                    
                    Button {
                        selectedUserId = "Kir_Kanos"
                    } label: {
                        Text("Kir_Kanos")
                            .padding()
                            .background(selectedUserId == "Kir_Kanos" ? Color.blue : .clear)
                            .cornerRadius(16)
                    }
                } else {
                    TextField("Insert livestream id", text: $livestreamId)
                        .padding()
                                    
                    NavigationLink {
                        LivestreamView(
                            callId: livestreamId,
                            pinnedProduct: .default,
                            isHost: true
                        )
                    } label: {
                        Text("Join as host")
                    }
                    .disabled(livestreamId.isEmpty || selectedUserId == nil)
                    .padding()
                    
                    Text("OR")
                    
                    NavigationLink {
                        LivestreamView(
                            callId: livestreamId,
                            pinnedProduct: .default,
                            isHost: false
                        )
                    } label: {
                        Text("Join as viewer")
                    }
                    .disabled(livestreamId.isEmpty || selectedUserId == nil)
                    .padding()
                }
            }
        }
    }
}
