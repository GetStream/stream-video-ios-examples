//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Select a user")
                .font(.title)
                .bold()
            
            List(UserCredentials.builtInUsers) { user in
                Button {
                    appState.login(user)
                } label: {
                    Text(user.userInfo.name)
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
