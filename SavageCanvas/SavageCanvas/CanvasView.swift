//
//  CanvasView.swift
//  Drawr
//
//  Created by Matthew Garden on 2016-09-08.
//  Copyright © 2016 Savagely Optimized. All rights reserved.
//

import UIKit

class CanvasView: UIView, DrawingToolDelegate {

    var width: CGFloat = 3
    var color: UIColor = .black
    var lineCapStyle: CGLineCap = .round
    
    private var drawableObjects: [Renderable] = []

    var tool: DrawingTool?
    
    private let defaultBackgroundColor: UIColor = .white
    
    // TODO: Implement encoding/decoding of CanvasView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = self.defaultBackgroundColor
        
        self.tool = SmoothInkPen(color: self.color, width: self.width, lineCapStyle: self.lineCapStyle)
        self.tool?.delegate = self
        self.tool?.addTo(view: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
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
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(self.drawableObjects, forKey: "drawableObjects")
    }

}
