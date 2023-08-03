//
//  ContentViewController.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import UIKit
import StreamVideo
import Combine

final class ContentViewController: UIViewController {
    
    private let call: Call
    private let state: CallState
    private var callCreated: Bool = false {
        didSet {
            var content = contentView.content
            content.callCreated = true
            contentView.content = content
        }
    }

    private var client: StreamVideo
    private let apiKey: String = "" // The API key can be found in the Credentials section
    private let userId: String = "" // The User Id can be found in the Credentials section
    private let token: String = "" // The Token can be found in the Credentials section
    private let callId: String = "" // The CallId can be found in the Credentials section

    private var joinCallTask: Task<Void, Error>?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var contentView: ContentView = .init(call: call)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    init() {
        let user = User(
            id: userId,
            name: "Martin", // name and imageURL are used in the UI
            imageURL: .init(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/a3911/martin-mitrevski.webp")
        )
        
        // Initialize Stream Video client
        self.client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )
        
        // Initialize the call object
        let call = client.call(callType: "audio_room", callId: callId)
        
        self.call = call
        self.state = call.state
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])

        joinCallTask = Task {
            guard !callCreated else { return }
            try await call.join(
                create: true,
                options: .init(
                    members: [
                        .init(userId: "john_smith"),
                        .init(userId: "jane_doe"),
                    ],
                    custom: [
                        "title": .string("SwiftUI heads"),
                        "description": .string("Talking about SwiftUI")
                    ]
                )
            )
            callCreated = true
        }
    }
}
