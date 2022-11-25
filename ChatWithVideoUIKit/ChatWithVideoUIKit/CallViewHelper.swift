//
//  CallViewHelper.swift
//  ChatWithVideoUIKit
//
//  Created by Martin Mitrevski on 25.11.22.
//

import UIKit

class CallViewHelper {
    
    static let shared = CallViewHelper()
    
    private var callView: UIView?
    
    private init() {}
    
    func add(callView: UIView) {
        guard self.callView == nil else { return }
        guard let window = UIApplication
            .shared
            .connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first else {
            return
        }
        callView.isOpaque = false
        callView.backgroundColor = UIColor.clear
        self.callView = callView
        window.addSubview(callView)
    }
    
    func removeCallView() {
        callView?.removeFromSuperview()
        callView = nil
    }
}
