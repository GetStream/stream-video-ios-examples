//
//  PlayerView.swift
//  LivestreamingSample
//
//  Created by Martin Mitrevski on 8.5.23.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    
    @StateObject var playerHelper: PlayerHelper
    
    init(url: URL) {
        _playerHelper = StateObject(wrappedValue: PlayerHelper(url: url))
    }
        
    var body: some View {
        ZStack {
            VideoPlayer(player: playerHelper.player)
                .opacity(playerHelper.waitingForStreamStart ? 0 : 1)
            
            VStack(spacing: 16) {
                Text("Waiting for live stream to start")
                    .foregroundColor(.white)
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .opacity(playerHelper.waitingForStreamStart ? 1 : 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                playerHelper.setupPlayer()
            })
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

class PlayerHelper: ObservableObject {
    
    @Published var player: AVPlayer
    @Published var waitingForStreamStart: Bool
    private let url: URL
    private var resetingPlayer = false
    private let initialTime: UInt32
    
    init(url: URL) {
        self.url = url
        let playerItem = AVPlayerItem(url: url)
        initialTime = playerItem.asset.duration.flags.rawValue
        self.waitingForStreamStart = true
        self.player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(rateChanged), name: AVPlayer.rateDidChangeNotification, object: nil)
    }

    
    func setupPlayer() {
        player.automaticallyWaitsToMinimizeStalling = false
        player.rate = 1
        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        player.play()
    }
    
    @objc func rateChanged(_ notification: Notification) {
        let duration = player.currentItem?.asset.duration.flags.rawValue ?? 0
        if player.rate == 1 && duration > 1 && self.waitingForStreamStart {
            self.waitingForStreamStart = false
        }

        if player.rate == 0 && !resetingPlayer && duration <= initialTime {
            resetingPlayer = true
            let timeInterval = TimeInterval(Int.random(in: 1...2))
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: { [weak self] in
                guard let self = self else { return }
                let playerItem = AVPlayerItem(url: self.url)
                self.player = AVPlayer(playerItem: playerItem)
                self.player.play()
                self.resetingPlayer = false
            })
        }
    }
    
}
