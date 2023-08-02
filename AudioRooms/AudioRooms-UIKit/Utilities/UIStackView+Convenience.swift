//
//  UIStackView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit

extension UIStackView {

    func withVerticalAxis() -> Self {
        self.axis = .vertical
        return self
    }

    func withHorizontalAxis() -> Self {
        self.axis = .horizontal
        return self
    }
}
