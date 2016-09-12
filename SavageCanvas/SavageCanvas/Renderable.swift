//
//  Renderable.swift
//  Drawr
//
//  Created by Matthew Garden on 2016-09-11.
//  Copyright © 2016 Savagely Optimized. All rights reserved.
//

import UIKit

protocol Renderable: NSCoding {
    var bounds: CGRect { get }
    func render()
}

protocol DrawingTool {
    
    weak var delegate: DrawingToolDelegate? { get set }
    
    func addTo(view: UIView)
    func removeFromView()
}

protocol DrawingToolDelegate: class {
    
    func drawingTool(_ drawingTool: DrawingTool, didAddRenderable renderable: Renderable)
    
    func drawingTool(_ drawingTool: DrawingTool, didUpdateRenderable renderable: Renderable, in rect: CGRect)
}
