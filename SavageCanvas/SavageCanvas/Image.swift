//
//  Image.swift
//  SavageCanvas
//
//  Created by Matthew Garden on 2016-10-11.
//  Copyright © 2016 Savagely Optimized. All rights reserved.
//

import Foundation
import ImageIO
import MobileCoreServices

extension Sequence where Iterator.Element == Renderable {
    
    func renderToImage(size: CGSize) -> UIImage? {
       
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        UIColor.clear.set()
        UIRectFill(rect)
        
        self.forEach { $0.render() }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

public extension CanvasView {
    
    public func renderToImage() -> UIImage? {
        
        return self.drawableObjects.renderToImage(size: self.frame.size)
    }
    
    public func renderToImageSequence() -> [UIImage] {
        
        var images: [UIImage] = []
        
        for i in 0 ..< self.drawableObjects.count {
        
            if let image = self.drawableObjects[0...i].renderToImage(size: self.frame.size) {
                images.append(image)
            }
        }
        
        return images
    }
}

public extension UIImage {
    
    public func writeToTemporaryURL() -> URL? {
        
        let fileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "image.png")
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        guard let _ = try? self.write(to: fileURL) else {
            return nil
        }
        
        return fileURL
    }
    
    public func write(to url: URL) throws {
        let data = UIImagePNGRepresentation(self)
        try data?.write(to: url)
    }
}

public extension Collection where Iterator.Element == UIImage {
    
    public func writeToTemporaryURL() -> URL? {
        
        let fileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "image.png")
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        guard let _ = try? self.write(to: fileURL) else {
            return nil
        }
        
        return fileURL
    }
    
    public func write(to url: URL) throws {
        
        let frameDelay: TimeInterval = 0.1
        
        let innerFileProperties = [kCGImagePropertyAPNGLoopCount as String: 0 as NSNumber] as CFDictionary
        let fileProperties = [kCGImagePropertyPNGDictionary as String: innerFileProperties] as CFDictionary
        
        let innerFrameProperties = [kCGImagePropertyAPNGDelayTime as String: frameDelay as NSNumber] as CFDictionary
        let frameProperties = [kCGImagePropertyPNGDictionary as String: innerFrameProperties] as CFDictionary
        
        let count: Int = Int(self.count.toIntMax())
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, count, nil) else {
            throw SavageCanvasError.imageCreation(url: url)
        }
        
        CGImageDestinationSetProperties(destination, fileProperties)
        
        self.flatMap { $0.cgImage }.forEach {
            CGImageDestinationAddImage(destination, $0, frameProperties)
        }
        
        if !CGImageDestinationFinalize(destination) {
            throw SavageCanvasError.imageFinalization
        }
    }
}

