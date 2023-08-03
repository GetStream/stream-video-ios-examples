//
//  ParticipantView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit
import StreamVideo
import Combine
import NukeUI

final class ParticipantView: UIView {

    lazy var imageview: LazyImageView = .init()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    var content: CallParticipant? {
        didSet { updateContent() }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    init(participant: CallParticipant?) {
        self.content = participant
        super.init(frame: .zero)
        
        addSubview(imageview)
        imageview.pin(to: self)

        setUpAppearance()
        updateContent()
    }

    func setUpAppearance() {
        clipsToBounds = true
        imageview.contentMode = .scaleAspectFit
        imageview.placeholderImage = .init(systemName: "person.crop.circle")
        imageview.failureImage = .init(systemName: "person.crop.circle")
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBackground.cgColor
    }

    func updateContent() {
        imageview.url = content?.profileImageURL
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2

        layer.borderColor = (content?.isSpeaking ?? false)
        ? UIColor.systemGreen.cgColor
        : UIColor.gray.cgColor
    }
}

final class ParticipantCollectionViewCell: UICollectionViewCell {
    
    var content: CallParticipant? {
        didSet { updateContent() }
    }
    
    lazy var participantView: ParticipantView = .init(participant: content)
        .withoutTranslatesAutoresizingMaskIntoConstraints()
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(participantView)
        participantView.pin(to: contentView)
        
        contentView.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            participantView.widthAnchor.constraint(equalTo: participantView.heightAnchor),
            participantView.heightAnchor.constraint(greaterThanOrEqualToConstant: 68)
        ])
    }
    
    func updateContent() {
        participantView.content = content
    }
}
