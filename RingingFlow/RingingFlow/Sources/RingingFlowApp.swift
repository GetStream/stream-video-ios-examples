//
//  RingingFlowApp.swift
//  RingingFlow
//
//  Created by Ilias Pavlidakis on 9/5/24.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI
import Combine

@main
struct RingingFlowApp: App {

    private final class ViewModel: ObservableObject {

        @Injected(\.streamVideo) var streamVideo
        @Injected(\.callKitAdapter) var callKitAdapter
        @Injected(\.callKitPushNotificationAdapter) var callKitPushNotificationAdapter
        @Published private(set) var isReady = false

        private var streamVideoUI: StreamVideoUI?
        var lastVoIPToken: String?
        var voIPTokenObservationCancellable: AnyCancellable?

        func onAppear(
            apiKey: String,
            userId: String,
            token: String
        ) {
            guard !isReady else { return }

            LogConfig.level = .debug

            streamVideo = .init(
                apiKey: apiKey,
                user: .init(id: userId),
                token: .init(stringLiteral: token),
                pushNotificationsConfig: .default
            )

            streamVideoUI = .init(streamVideo: streamVideo)

            callKitAdapter.streamVideo = streamVideo

            voIPTokenObservationCancellable = callKitPushNotificationAdapter
                .$deviceToken
                .sink { [streamVideo] updatedDeviceToken in
                    Task { [weak self] in
                        if let lastVoIPToken = self?.lastVoIPToken {
                            try await streamVideo.deleteDevice(id: lastVoIPToken)
                        }
                        try await streamVideo.setVoipDevice(id: updatedDeviceToken)
                        self?.lastVoIPToken = updatedDeviceToken
                    }
                }

            callKitAdapter.registerForIncomingCalls()

            Task { @MainActor in
                do {
                    try await streamVideo.connect()
                    isReady = true
                } catch {
                    log.error(error)
                    isReady = false
                }
            }
        }
    }

    @StateObject private var viewModel = ViewModel()
    @StateObject private var callViewModel = CallViewModel(
        callSettings: .init(
            audioOn: true,
            videoOn: false,
            speakerOn: false
        )
    )
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if viewModel.isReady {
                ContentView(callViewModel: callViewModel)
            } else {
                Text("Connecting...")
                    .onAppear {
                        viewModel.onAppear(
                            apiKey: Configuration.apiKey,
                            userId: Configuration.userId,
                            token: Configuration.token
                        )
                    }
            }
        }
    }
}
