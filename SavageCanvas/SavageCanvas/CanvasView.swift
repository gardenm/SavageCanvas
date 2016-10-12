//
//  CanvasView.swift
//  Drawr
//
//  Created by Matthew Garden on 2016-09-08.
//  Copyright © 2016 Savagely Optimized. All rights reserved.
//

import UIKit

public class CanvasView: UIView, DrawingToolDelegate {

    var width: CGFloat = 3
    var color: UIColor = .black
    var lineCapStyle: CGLineCap = .round
    
    fileprivate var drawableObjects: [Renderable] = []

    var tool: DrawingTool?
    
    fileprivate let defaultBackgroundColor: UIColor = .white
    
    // TODO: Implement encoding/decoding of CanvasView
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = self.defaultBackgroundColor
        
        self.tool = SmoothInkPen(color: self.color, width: self.width, lineCapStyle: self.lineCapStyle)
        self.tool?.delegate = self
        self.tool?.addTo(view: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.color.setStroke()
        
        // There are probably more efficient ways of handling this
        for object in drawableObjects where object.bounds.intersects(rect) {
            object.render()
        }
    }
    
    // MARK: - DrawingToolDelegate
    
    func drawingTool(_ drawingTool: DrawingTool, didAddRenderable renderable: Renderable) {
        self.drawableObjects.append(renderable)
    }
    
    func drawingTool(_ drawingTool: DrawingTool, didUpdateRenderable renderable: Renderable, in rect: CGRect) {
        self.setNeedsDisplay(rect)
    }
    
    // MARK: - NSCoding
    
    override public func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(self.drawableObjects, forKey: "drawableObjects")
    }
}

public extension CanvasView {
    
    public func renderToImage() -> UIImage? {
        let rect = CGRect(origin: .zero, size: self.frame.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        UIColor.clear.set()
        UIRectFill(rect)

        self.drawableObjects.forEach {
            $0.render()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func renderToImageOnDisk() -> URL? {
        
        guard let image = self.renderToImage() else {
            return nil
        }
        
        let fileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "image.png")
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        let data = UIImagePNGRepresentation(image)
        guard let _ = try? data?.write(to: fileURL) else {
            return nil
        }
        
        return fileURL
    }
}
