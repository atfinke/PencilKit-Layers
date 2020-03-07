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
}
