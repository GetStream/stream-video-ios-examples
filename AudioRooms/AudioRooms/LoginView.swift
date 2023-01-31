//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel: LoginViewModel
    var completion: (UserCredentials) -> ()
    
    @State var addUserShown = false
    
    init(completion: @escaping (UserCredentials) -> ()) {
        _viewModel = StateObject(wrappedValue: LoginViewModel())
        self.completion = completion
    }
    
    var body: some View {
        VStack {
            Text("Select a user")
                .font(.title)
                .bold()
            List(viewModel.userCredentials) { user in
                Button {
                    viewModel.login(user: user, completion: completion)
                } label: {
                    Text(user.userInfo.name)
                }
                .padding(.all, 8)
            }
        }
        .foregroundColor(.primary)
        .overlay(
            viewModel.loading ? ProgressView() : nil
        )
    }
}
