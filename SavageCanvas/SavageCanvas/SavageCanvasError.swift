//
//  SavageCanvasError.swift
//  SavageCanvas
//
//  Created by Matthew Garden on 2016-10-12.
//  Copyright © 2016 Savagely Optimized. All rights reserved.
//

import Foundation

public enum SavageCanvasError: Error {
    
    /**
     An error occurred when creating an image.
     - parameter url: The file url of the image which could not be created.
     */
    case imageCreation(url: URL)
    
    /**
     An error occurred when finalizing a new image.
     */
    case imageFinalization
}
