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
        
        let size = self.frame.size
        var images: [UIImage] = []
        
        for i in 0 ..< self.drawableObjects.count {
        
            if let image = self.drawableObjects[0...i].renderToImage(size: size) {
                images.append(image)
            }
        }
        
        if !images.isEmpty, let blankImage = UIImage.image(color: .clear, size: size) {
            images.insert(blankImage, at: 0)
        }
        
        return images
    }
}

public extension UIImage {
    
    internal class func image(color: UIColor, size: CGSize) -> UIImage? {
        
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        color.set()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func writeToTemporaryURL() throws -> URL {
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        return try self.write(toFileAtDirectoryURL: url)
    }
    
    public func write(toFileAtDirectoryURL url: URL) throws -> URL {
        
        guard let fileName = (ProcessInfo.processInfo.globallyUniqueString as NSString).appendingPathExtension("png") else {
            
            throw SavageCanvasError.imageCreation(url: url)
        }
        
        let fileURL = url.appendingPathComponent(fileName)
        try self.write(to: fileURL)
        
        return fileURL
    }
    
    public func write(to url: URL) throws {
        let data = UIImagePNGRepresentation(self)
        try data?.write(to: url)
    }
}

public extension Collection where Iterator.Element == UIImage {
    
    public func writeToTemporaryURL() throws -> URL {
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        return try self.write(toFileAtDirectoryURL: url)
    }
    
    public func write(toFileAtDirectoryURL url: URL) throws -> URL {
        
        guard let fileName = (ProcessInfo.processInfo.globallyUniqueString as NSString).appendingPathExtension("png") else {
            
            throw SavageCanvasError.imageCreation(url: url)
        }
        
        let fileURL = url.appendingPathComponent(fileName)
        try self.write(to: fileURL)
        
        return fileURL
    }
    
    public func write(to url: URL) throws {
        
        let frameDelay: TimeInterval = 0.2
        
        let innerFileProperties = [kCGImagePropertyAPNGLoopCount as String: 0 as NSNumber]
        let fileProperties = [kCGImagePropertyPNGDictionary as String: innerFileProperties]
        
        let innerFrameProperties = [kCGImagePropertyAPNGDelayTime as String: frameDelay as NSNumber]
        let frameProperties = [kCGImagePropertyPNGDictionary as String: innerFrameProperties]
        
        let count: Int = Int(self.count.toIntMax())
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, count, nil) else {
            throw SavageCanvasError.imageCreation(url: url)
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        self.flatMap { $0.cgImage }.forEach {
            CGImageDestinationAddImage(destination, $0, frameProperties as CFDictionary)
        }
        
        if !CGImageDestinationFinalize(destination) {
            throw SavageCanvasError.imageFinalization
        }
    }
}

