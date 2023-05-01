//
//  CreateRoomForm.swift
//  AudioRooms
//
//  Created by Stefan Blos on 28.04.23.
//

import SwiftUI
import StreamVideo

struct CreateRoomForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: CreateRoomViewModel
    
    @State private var title: String = ""
    @State private var description: String = ""
    
    var buttonDisabled: Bool {
        title.isEmpty || description.isEmpty
    }
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: CreateRoomViewModel(user: user))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title of the room", text: $title)
                    Text("This describes the title of the room.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                    
                    TextField("Description", text: $description)
                    Text("Give more detail about what this room is for.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                } header: {
                    Text("Room information")
                }
                
                Button {
                    viewModel.createRoom(title: title, description: description)
                    dismiss()
                } label: {
                    Text("Create")
                }
                .disabled(buttonDisabled)

            }
            .navigationTitle("Create Room")
            .toolbar {
                Button("Close", role: .destructive) {
                    dismiss()
                }
            }
        }
    }
}

struct CreateRoomForm_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomForm(user: .anonymous)
    }
}
