//
//  PermissionRequestsView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit
import StreamVideo
import Combine

final class PermissionRequestsView: UIView {

    private let call: Call
    private var cancellable: AnyCancellable?

    private var content: PermissionRequest? {
        didSet { updateContent() }
    }

    lazy var container: UIStackView = .init()
        .withHorizontalAxis()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var titleLabel: UILabel = .init()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var acceptButton: UIButton = .init(type: .system)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var rejectButton: UIButton = .init(type: .system)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    init(call: Call) {
        self.call = call

        super.init(frame: .zero)

        subscribeToPermissionRequestUpdates()

        addSubview(container)
        container.pin(to: self)

        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(acceptButton)
        container.addArrangedSubview(rejectButton)

        NSLayoutConstraint.activate([
            acceptButton.widthAnchor.constraint(equalToConstant: 50),
            acceptButton.heightAnchor.constraint(equalToConstant: 50),
            rejectButton.widthAnchor.constraint(equalTo: acceptButton.widthAnchor),
            rejectButton.heightAnchor.constraint(equalTo: acceptButton.heightAnchor),
        ])

        setUpAppearance()
        updateContent()
    }

    func setUpAppearance() {
        titleLabel.textColor = .label
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.numberOfLines = 2

        acceptButton.setImage(.init(systemName: "hand.thumbsup.circle"), for: .normal)
        acceptButton.tintColor = .systemGreen
        acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)

        rejectButton.setImage(.init(systemName: "hand.thumbsdown.circle"), for: .normal)
        rejectButton.tintColor = .systemRed
        acceptButton.addTarget(self, action: #selector(reject), for: .touchUpInside)
    }

    func updateContent() {
        guard let request = content else {
            container.isHidden = true
            return
        }

        container.isHidden = false
        titleLabel.text = "\(request.user.name) requested to \(request.permission)"
    }

    private func subscribeToPermissionRequestUpdates() {
        cancellable = call
            .state
            .$permissionRequests
            .receive(on: DispatchQueue.main)
            .map { $0.first }
            .sink { [weak self] in self?.content = $0 }
    }

    @objc
    private func accept() {
        guard let request = content else { return }
        Task {
            try await call.grant(request: request)
            content = nil
        }
    }

    @objc
    private func reject() {
        guard let request = content else { return }
        request.reject()
        content = nil
    }
}
