//
//  StreamWrapper.swift
//  LivestreamingSampleApp
//
//  Created by Martin Mitrevski on 14.11.22.
//

import Foundation
import StreamVideo
import StreamVideoSwiftUI

typealias StreamTokenProvider = (@escaping (Result<String, Error>) -> Void) -> Void

class StreamWrapper {
    let streamVideo: StreamVideo
    let streamVideoUI: StreamVideoUI
    var tokenProvider: StreamTokenProvider
    
    init(
        apiKey: String,
        userCredentials: UserCredentials,
        videoFilters: [VideoFilter] = [],
        tokenProvider: @escaping StreamTokenProvider
    ) {
        self.tokenProvider = tokenProvider
        let token = userCredentials.tokenValue
        streamVideo = StreamVideo(
            apiKey: apiKey,
            user: userCredentials.user,
            token: try! UserToken(rawValue: token),
            videoConfig: VideoConfig(
                videoFilters: videoFilters
            ),
            tokenProvider: { result in
                tokenProvider { tokenResult in
                    switch tokenResult {
                    case .success(let rawValue):
                        do {
                            let updatedToken = try UserToken(rawValue: rawValue)
                            result(.success(updatedToken))
                        } catch {
                            result(.failure(error))
                        }
                    case .failure(let error):
                        result(.failure(error))
                    }
                }
            }
        )
        streamVideoUI = StreamVideoUI(streamVideo: streamVideo)
        Task {
            try await streamVideoUI.connect()
        }
    }
    
    func logout() async {
        await streamVideo.disconnect()
    }    
}

