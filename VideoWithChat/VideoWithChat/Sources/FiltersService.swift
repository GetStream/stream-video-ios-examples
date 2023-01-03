//
//  FiltersService.swift
//  VideoWithChat
//
//  Created by Martin Mitrevski on 2.1.23.
//

import Foundation
import UIKit
import StreamVideo
import Vision
import SwiftUI

class FiltersService: ObservableObject {
    @Published var filtersShown = false
    @Published var selectedFilter: VideoFilter?
    static let supportedFilters = [
        sepia, bloom, stream
    ]
    
    static let streamLogo: UIImage = {
        let image = UIImage(named: "stream")!
        return image.rotate(.degrees(-90))
    }()
    
    static let sepia: VideoFilter = {
        let sepia = VideoFilter(id: "sepia", name: "Sepia") { image in
            let sepiaFilter = CIFilter(name: "CISepiaTone")
            sepiaFilter?.setValue(image, forKey: kCIInputImageKey)
            return sepiaFilter?.outputImage ?? image
        }
        return sepia
    }()
    
    static let bloom: VideoFilter = {
        let bloom = VideoFilter(id: "bloom", name: "Bloom") { image in
            let bloomFilter = CIFilter(name: "CIBloom")
            bloomFilter?.setValue(image, forKey: kCIInputImageKey)
            return bloomFilter?.outputImage ?? image
        }
        return bloom
    }()
    
    static let stream: VideoFilter = {
        let stream = VideoFilter(id: "stream", name: "Stream") { image in
            guard let faceRect = try? await detectFaces(image: image) else { return image }
            let converted = convert(cmage: image)
            let bounds = image.extent
            let convertedRect = CGRect(
                x: faceRect.minX * bounds.width - 80,
                y: faceRect.minY * bounds.height,
                width: faceRect.width * bounds.width,
                height: faceRect.height * bounds.height
            )
            let overlayed = await drawImageIn(converted, size: bounds.size, streamLogo, inRect: convertedRect)
            
            
            let result = CIImage(cgImage: overlayed.cgImage!)
            return result
        }
        return stream
    }()
    
    static func convert(cmage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(cmage, from: cmage.extent)!
        let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        return image
    }
        
    @MainActor
    static func drawImageIn(_ image: UIImage, size: CGSize, _ logo: UIImage, inRect: CGRect) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: CGPoint.zero, size: size))
            logo.draw(in: inRect)
        }
    }
    
    static func detectFaces(image: CIImage) async throws -> CGRect {
        return try await withCheckedThrowingContinuation { continuation in
            let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
                if let result = request.results?.first as? VNFaceObservation {
                    continuation.resume(returning: result.boundingBox)
                } else {
                    continuation.resume(throwing: ClientError.Unknown())
                }
            }
            let vnImage = VNImageRequestHandler(ciImage: image, orientation: .downMirrored)
            try? vnImage.perform([detectFaceRequest])
        }
    }
    
    static func convertImageOrientation(orientation: UIImage.Orientation) -> CGImagePropertyOrientation  {
        let cgiOrientations : [ CGImagePropertyOrientation ] = [
            .up, .down, .left, .right, .upMirrored, .downMirrored, .leftMirrored, .rightMirrored
        ]

        return cgiOrientations[orientation.rawValue]
    }
    
    @MainActor
    static func detectFaces(image: CIImage) throws -> CGRect {
        var rect: CGRect = .zero
        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            if let result = request.results?.first as? VNFaceObservation {
                rect = result.boundingBox
            }
        }
        let vnImage = VNImageRequestHandler(ciImage: image)
        try? vnImage.perform([detectFaceRequest])
        return rect
    }
    
    static var window: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
    
    static var bounds: CGRect {
        UIScreen.main.bounds
    }
    
    static var scale: CGFloat {
        UIScreen.main.scale
    }
    
}

extension VideoFilter: Identifiable, Equatable {
    public static func == (lhs: VideoFilter, rhs: VideoFilter) -> Bool {
        lhs.id == rhs.id
    }
}

extension UIImage {
    public func rotate(_ angle: Angle) -> UIImage {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: angle.radians)).size

        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        let image = UIGraphicsImageRenderer(size:newSize).image { renderer in
            let context = renderer.cgContext
            //rotate from center
            context.translateBy(x: newSize.width/2, y: newSize.height/2)
            context.rotate(by: angle.radians)
            draw(in:  CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: size))
        }

        return image
    }
}
