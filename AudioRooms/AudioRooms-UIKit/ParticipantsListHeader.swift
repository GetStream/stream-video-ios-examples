//
//  ParticipantsListHeader.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit

final class ParticipantsListHeader: UICollectionReusableView {

    var content: String = "" {
        didSet { updateContent() }
    }

    lazy var titleLabel: UILabel = .init()
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        titleLabel.pin(to: self)

        setUpAppearance()
        updateContent()
    }

    func setUpAppearance() {
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        titleLabel.textColor = .label
    }

    func updateContent() {
        titleLabel.text = content
    }
}
