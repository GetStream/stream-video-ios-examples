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
            token: UserToken(rawValue: token),
            videoConfig: VideoConfig(
                videoFilters: videoFilters
            ),
            tokenProvider: { result in
                tokenProvider { tokenResult in
                    switch tokenResult {
                    case .success(let rawValue):
                        let updatedToken = UserToken(rawValue: rawValue)
                        result(.success(updatedToken))
                    case .failure(let error):
                        result(.failure(error))
                    }
                }
            }
        )
        streamVideoUI = StreamVideoUI(streamVideo: streamVideo)
    }
    
    func logout() async {
        await streamVideo.disconnect()
    }    
}

