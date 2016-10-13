//
//  SmoothInk.swift
//  Drawr
//
//  Created by Matthew Garden on 2016-09-11.
//  Copyright © 2016 Savagely Optimized. All rights reserved.
//

import UIKit

class SmoothInk: Renderable {
    
    let color: UIColor
    let path: UIBezierPath
    
    init(width: CGFloat, color: UIColor, lineCapStyle: CGLineCap) {
        
        self.color = color
        
        let path = UIBezierPath()
        path.lineWidth = width
        path.lineCapStyle = lineCapStyle
        self.path = path
    }
    
    var bounds: CGRect {
        return self.path.bounds
    }
    
    func render() {
        self.color.setStroke()
        self.path.stroke()
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {

        guard let color = aDecoder.decodeObject(forKey: "color") as? UIColor,
            let path = aDecoder.decodeObject(forKey: "path") as? UIBezierPath else {
                return nil
        }
        
        self.color = color
        self.path = path
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.color, forKey: "color")
        aCoder.encode(self.path, forKey: "path")
    }
}

private extension CGPoint {
    
    func midpoint(to other: CGPoint) -> CGPoint {
        let x = (self.x + other.x) / 2
        let y = (self.y + other.y) / 2
        return CGPoint(x: x, y: y)
    }
}

public class SmoothInkPen: DrawingTool {
    
    weak public var delegate: DrawingToolDelegate?

    var panGestureRecognizer: UIPanGestureRecognizer?
    var view: UIView?
    
    private var previousPoint: CGPoint?
    private var currentInk: SmoothInk?
    
    let color: UIColor
    let lineCapStyle: CGLineCap
    let width: CGFloat
    
    public init(color: UIColor, width: CGFloat, lineCapStyle: CGLineCap) {
        self.color = color
        self.lineCapStyle = lineCapStyle
        self.width = width
    }
    
    func update(ink: SmoothInk) {
        let path = ink.path
        let inset = -(path.lineWidth / 2)
        let bounds = path.bounds.insetBy(dx: inset, dy: inset)
        
        self.delegate?.drawingTool(self, didUpdateRenderable: ink, in: bounds)
    }
    
    @objc func pan(recognizer: UIGestureRecognizer) {
        
        guard let view = self.view else {
            return
        }
        
        let point = recognizer.location(in: view)
        
        if recognizer.state == .began {
            
            let ink = SmoothInk(width: self.width, color: self.color, lineCapStyle: self.lineCapStyle)
            ink.path.move(to: point)
            self.delegate?.drawingTool(self, didAddRenderable: ink)

            self.currentInk = ink
            
        } else if recognizer.state == .changed, let path = self.currentInk?.path, let previousPoint = self.previousPoint {
            
            let newPoint = point.midpoint(to: previousPoint)
            path.addQuadCurve(to: newPoint, controlPoint: previousPoint)
            
        } else if [.ended, .cancelled, .failed].contains(recognizer.state) {
            
            self.currentInk = nil
            return
        }
        
        self.previousPoint = point
        
        if let ink = self.currentInk {
            self.update(ink: ink)
        }
    }
    
    // MARK: - DrawingTool
    
    public func addTo(view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(recognizer:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        self.panGestureRecognizer = panGestureRecognizer
        self.view = view
    }
    
    public func removeFromView() {

        guard let panGestureRecognizer = self.panGestureRecognizer else {
            return
        }

        self.view?.removeGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = nil
    }
}
