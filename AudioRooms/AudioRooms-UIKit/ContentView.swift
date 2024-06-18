//
//  ContentView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit
import StreamVideo

final class ContentView: UIView {

    struct Content {
        var callCreated: Bool
        var callId: String
        var title: String
        var description: String?
        var participantCount: Int

        static let empty = Content(
            callCreated: false,
            callId: "",
            title: "",
            description: nil,
            participantCount: 0
        )
    }

    var content: Content = .empty {
        didSet { updateContent() }
    }

    lazy var container: UIStackView = .init()
        .withVerticalAxis()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var descriptionView: DescriptionView = .init(call: call)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var participantsView: ParticipantsView = .init(call: call)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var permissionRequestsView: PermissionRequestsView = .init(call: call)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var controlsView: ControlsView = .init(call: call)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    private let call: Call

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    init(call: Call) {
        self.call = call

        super.init(frame: .zero)

        addSubview(container)
        container.pin(to: self)

        updateContent()
    }

    func updateContent() {
        backgroundColor = .systemBackground

        container.arrangedSubviews.forEach {
            container.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        container.spacing = 8

        if content.callCreated {
            descriptionView.content = .init(
                title: content.title,
                description: content.description,
                participantsCount: content.participantCount
            )

            container.addArrangedSubview(descriptionView)
            container.addArrangedSubview(participantsView)
            container.addArrangedSubview(permissionRequestsView)
            container.addArrangedSubview(controlsView)
        } else {
            let label = UILabel().withoutTranslatesAutoresizingMaskIntoConstraints()
            label.text = "loading..."
            label.textAlignment = .center
            label.textColor = .label
            label.font = .preferredFont(forTextStyle: .body)

            let spacerA = UIView.spacer()
            let spacerB = UIView.spacer()

            container.addArrangedSubview(spacerA)
            container.addArrangedSubview(label)
            container.addArrangedSubview(spacerB)

            NSLayoutConstraint.activate([
                spacerA.heightAnchor.constraint(equalTo: spacerB.heightAnchor)
            ])
        }
    }
}
