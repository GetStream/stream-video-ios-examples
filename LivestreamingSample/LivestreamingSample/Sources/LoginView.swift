//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
            List {
                ForEach(viewModel.users) { user in
                    Button {
                        Task {
                            try await viewModel.login(user: user, completion: completion)
                        }
                    } label: {
                        Text(user.name)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 8)
                }

                Button {
                    viewModel.loginAnonymously(completion: completion)
                } label: {
                    Text("Anonymous User")
                        .accessibility(identifier: "Login as Anonymous")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 8)
            }
        }
        .foregroundColor(.primary)
        .overlay(
            viewModel.loading ? ProgressView() : nil
        )
    }
}
