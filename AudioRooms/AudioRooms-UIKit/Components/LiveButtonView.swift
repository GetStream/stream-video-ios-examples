//
//  LiveButtonView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit
import StreamVideo
import Combine

final class LiveButtonView: UIView {

    var content: Bool = true {
        didSet { updateContent() }
    }

    lazy var goLiveButton: UIButton = .init(type: .system)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var stopLiveButton: UIButton = .init(type: .system)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    private let call: Call
    private var cancellables: Set<AnyCancellable> = []
    private var activeTask: Task<Void, Error>?

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    init(call: Call) {
        self.call = call

        super.init(frame: .zero)

        subscribeToBackstageUpdates()

        setUpAppearance()
        updateContent()
    }

    deinit {
        activeTask?.cancel()
    }

    func setUpAppearance() {
        goLiveButton.setTitle("Go Live", for: .normal)
        goLiveButton.backgroundColor = .systemGreen
        goLiveButton.layer.cornerRadius = 8
        goLiveButton.setTitleColor(.darkText, for: .normal)
        goLiveButton.addTarget(self, action: #selector(goLive), for: .touchUpInside)

        stopLiveButton.setTitle("Stop Live", for: .normal)
        stopLiveButton.backgroundColor = .systemRed
        stopLiveButton.layer.cornerRadius = 8
        stopLiveButton.setTitleColor(.label, for: .normal)
        stopLiveButton.addTarget(self, action: #selector(stopLive), for: .touchUpInside)
    }

    func updateContent() {
        if content {
            stopLiveButton.removeFromSuperview()
            addSubview(goLiveButton)
            goLiveButton.pin(to: self)
        } else {
            goLiveButton.removeFromSuperview()
            addSubview(stopLiveButton)
            stopLiveButton.pin(to: self)
        }
    }

    private func subscribeToBackstageUpdates() {
        call.state
            .$backstage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.content = $0 }
            .store(in: &cancellables)
    }

    @objc
    private func goLive() {
        activeTask?.cancel()
        activeTask = Task {
            try await call.goLive()
        }
    }

    @objc
    private func stopLive() {
        activeTask?.cancel()
        activeTask = Task {
            try await call.stopLive()
        }
    }
}
