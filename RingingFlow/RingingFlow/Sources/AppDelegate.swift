//
//  AppDelegate.swift
//  RingingFlow
//
//  Created by Ilias Pavlidakis on 10/5/24.
//

import Foundation
import UIKit
import StreamVideo

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        InjectedValues[\.callKitService] = CustomCallKitService()
        return true
    }
}
