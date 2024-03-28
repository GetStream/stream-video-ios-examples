//
//  DescriptionView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit
import StreamVideo
import Combine

final class DescriptionView: UIView {

    struct Content {
        var title: String
        var description: String?
        var participantsCount: Int

        static let empty: Content = .init(title: "", participantsCount: 0)
    }

    var content: Content = .empty {
        didSet { updateContent() }
    }

    lazy var container: UIStackView = .init()
        .withVerticalAxis()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var titleLabel: UILabel = .init()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var descriptionLabel: UILabel = .init()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    lazy var participantsCountLabel: UILabel = .init()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    private let call: Call
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    init(call: Call) {
        self.call = call

        super.init(frame: .zero)

        addSubview(container)
        container.pin(to: self)

        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(descriptionLabel)
        container.addArrangedSubview(participantsCountLabel)

        subscribeToParticipantsUpdates()
        subscribeToParticipantsUpdates()

        setUpAppearance()
        updateContent()
    }

    func setUpAppearance() {
        container.spacing = 8

        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .label

        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .secondaryLabel

        participantsCountLabel.font = .preferredFont(forTextStyle: .caption1)
        participantsCountLabel.textColor = .secondaryLabel
        }

    func updateContent() {
        titleLabel.text = content.title
        descriptionLabel.isHidden = content.description == nil
        descriptionLabel.text = content.description
        participantsCountLabel.text = "\(content.participantsCount) participants"
    }

    private func subscribeToParticipantsUpdates() {
        call.state
            .$participants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                var content = self.content
                content.participantsCount = newValue.count
                self.content = content
            }.store(in: &cancellables)
    }

    private func subscribeToCustomUpdates() {
        call.state
            .$custom
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                var content = self.content
                content.title = newValue["title"]?.stringValue ?? ""
                content.description = newValue["description"]?.stringValue
                self.content = content
            }.store(in: &cancellables)
    }
}
