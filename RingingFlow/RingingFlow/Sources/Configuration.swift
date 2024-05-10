//
//  Configuration.swift
//  RingingFlow
//
//  Created by Ilias Pavlidakis on 10/5/24.
//

import Foundation

enum Configuration {
    
    static let apiKey = "YOU_API_KEY"
    #if targetEnvironment(simulator)
    static let token  = "USER_A_TOKEN"
    static let userId = "USER_A_ID"
    static let otherUserId = "USER_B_ID"
    #else
    static let  token  = "USER_B_TOKEN"
    static let userId = "USER_B_ID"
    static let otherUserId = "USER_A_ID"
    #endif
}
