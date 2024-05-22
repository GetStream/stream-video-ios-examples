//
//  Configuration.swift
//  RingingFlow
//
//  Created by Ilias Pavlidakis on 10/5/24.
//

import Foundation

enum Configuration {

    static let apiKey = "mmhfdzb5evj2"
    #if targetEnvironment(simulator)
    static let token  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiR3JhbmRfTW9mZl9UYXJraW4iLCJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0dyYW5kX01vZmZfVGFya2luIiwiaWF0IjoxNzE2NDAwODI3LCJleHAiOjE3MTcwMDU2MzJ9.6pKcd0oKCaZBjwosqKAN8EOvqRKl0RKwa9exBsyOJVQ"
    static let userId = "Grand_Moff_Tarkin"
    static let otherUserId = "Zayne_Carrick"

    /// User A
    /// token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiR3JhbmRfTW9mZl9UYXJraW4iLCJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0dyYW5kX01vZmZfVGFya2luIiwiaWF0IjoxNzE2NDAwODI3LCJleHAiOjE3MTcwMDU2MzJ9.6pKcd0oKCaZBjwosqKAN8EOvqRKl0RKwa9exBsyOJVQ
    /// userId: Grand_Moff_Tarkin
    ///
    /// User B
    /// token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiQmFycmlzc19PZmZlZSIsImlzcyI6Imh0dHBzOi8vcHJvbnRvLmdldHN0cmVhbS5pbyIsInN1YiI6InVzZXIvQmFycmlzc19PZmZlZSIsImlhdCI6MTcxNjQwMDgyNiwiZXhwIjoxNzE3MDA1NjMxfQ.DEE5PkKgOmmaWtGx-bgtoUb5UA6wYOFKk9AkgBR_4jY"
    /// userId: Barriss_Offee

    #else
    static let token  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiWmF5bmVfQ2FycmljayIsImlzcyI6Imh0dHBzOi8vcHJvbnRvLmdldHN0cmVhbS5pbyIsInN1YiI6InVzZXIvWmF5bmVfQ2FycmljayIsImlhdCI6MTcxNjQwMDgzMCwiZXhwIjoxNzE3MDA1NjM1fQ.mvV6lmzRFtOucz75W2EmEVBHBW9jk38Zp8kpeiAEzY0"
    static let userId = "Zayne_Carrick"
    static let otherUserId = "Barriss_Offee"
    #endif

    static let allowCallRingingWhileInCall = false
}
