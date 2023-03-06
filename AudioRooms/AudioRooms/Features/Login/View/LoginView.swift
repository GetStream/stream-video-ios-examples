//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamVideo

struct LoginView: View {
    
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Select a user")
                .font(.title)
                .bold()
            
            List(User.builtInUsers) { user in
                Button {
                    Task {
                        try await appState.login(user)
                    }
                } label: {
                    Text(user.name)
                }
                .padding(8)
            }
        }
        .foregroundColor(.primary)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(appState: AppState())
    }
}
