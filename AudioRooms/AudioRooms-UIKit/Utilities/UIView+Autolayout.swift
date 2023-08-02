//
//  UIView+Autolayout.swift
//  AudioRooms-SwiftUI
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit

extension UIView {

    func withoutTranslatesAutoresizingMaskIntoConstraints() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    func pin(to superview: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor),
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    static func spacer() -> UIView {
        UIStackView()
            .withoutTranslatesAutoresizingMaskIntoConstraints()
    }
}
