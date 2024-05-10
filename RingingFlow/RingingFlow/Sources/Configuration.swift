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
    static let token  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiR2VuZXJhbF9Eb2Rvbm5hIiwiaXNzIjoiaHR0cHM6Ly9wcm9udG8uZ2V0c3RyZWFtLmlvIiwic3ViIjoidXNlci9HZW5lcmFsX0RvZG9ubmEiLCJpYXQiOjE3MTUyNDkxMjEsImV4cCI6MTcxNTg1MzkyNn0.o5UrAPHXq1KhJNT3Wii5bFKFRbKaAGS_lxd_ExDDlGw"
    static let userId = "General_Dodonna"
    static let otherUserId = "Kyle_Katarn"
    #else
    static let  token  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiS3lsZV9LYXRhcm4iLCJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0t5bGVfS2F0YXJuIiwiaWF0IjoxNzE1MjU3NjczLCJleHAiOjE3MTU4NjI0Nzh9.dhGtcb_JrRmfR9XLXlHHpFfVIoS0H7oEkXR_D67-W8c"
    static let userId = "Kyle_Katarn"
    static let otherUserId = "General_Dodonna"
    #endif
}
