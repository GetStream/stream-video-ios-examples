//
//  MicButtonView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit
import StreamVideo
import Combine

final class MicButtonView: UIButton {

    private let microphone: MicrophoneManager
    private var cancellable: AnyCancellable?
    private var toggleTask: Task<Void, Error>?

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    init(microphone: MicrophoneManager) {
        self.microphone = microphone
        super.init(frame: .zero)

        subscribeToMicrophoneStatusUpdates()

        setUpAppearance()
    }

    deinit {
        toggleTask?.cancel()
    }

    func setUpAppearance() {
        setImage(.init(systemName: "mic.circle"), for: .normal)
        addTarget(self, action: #selector(toggleMic), for: .touchUpInside)
    }

    @objc
    func toggleMic() {
        toggleTask?.cancel()
        toggleTask = Task {
            try await microphone.toggle()
        }
    }

    private func subscribeToMicrophoneStatusUpdates() {
        cancellable = microphone
            .$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.setImage(.init(systemName: newValue == .enabled ? "mic.circle" : "mic.slash.circle"), for: .normal)
                self?.tintColor = newValue == .enabled ? .systemBlue : .systemRed
            }
    }
}
