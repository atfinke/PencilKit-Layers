//
//  Design.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

struct Design {
    static let thumbnailWidth: CGFloat = 120.0
    static var thumbnailHeight: CGFloat = {
        let screenBounds = UIScreen.main.bounds
        let aspectRatio = screenBounds.width / screenBounds.height
        return thumbnailWidth * (1 / (screenBounds.width / screenBounds.height))
    }()
    static var thumbnailSize: CGSize = {
        return CGSize(width: thumbnailWidth, height: thumbnailHeight)
    }()
    static var thumbnailWidthPadding: CGFloat = 35
    static var thumbnailHeightPadding: CGFloat = 35
    
    static let thumbnailAddButtonSize = CGSize(width: 50, height: 50)
    static let thumbnailAddButtonScaleFactor: CGFloat = 0.8
    static let thumbnailAddButtonScaleDuration = 0.4
    static let thumbnailAddButtonScaleDamping: CGFloat = 0.75
    static let thumbnailAddButtonScaleVelocity: CGFloat = 0.75
}
