//
//  PreJoiningViewModel.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 18.1.23.
//

import SwiftUI
import AVFoundation

class PreJoiningViewModel: ObservableObject {
    let camera = Camera()
 
    @Published var viewfinderImage: Image?
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0.image }

        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}
