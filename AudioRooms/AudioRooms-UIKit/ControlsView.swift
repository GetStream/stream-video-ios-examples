//
//  ControlsView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit
import StreamVideo

final class ControlsView: UIView {

    lazy var container: UIStackView = .init()
        .withHorizontalAxis()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var micButtonView: MicButtonView = .init(microphone: call.microphone)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var liveButtonView: LiveButtonView = .init(call: call)
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let call: Call

    init(call: Call) {
        self.call = call

        super.init(frame: .zero)

        addSubview(container)
        container.pin(to: self)

        container.spacing = 8

        let spacerA = UIView.spacer()
        let spacerB = UIView.spacer()

        container.addArrangedSubview(spacerA)
        container.addArrangedSubview(micButtonView)
        container.addArrangedSubview(liveButtonView)
        container.addArrangedSubview(spacerB)

        NSLayoutConstraint.activate([
            spacerA.widthAnchor.constraint(equalTo: spacerB.widthAnchor)
        ])
    }
}

