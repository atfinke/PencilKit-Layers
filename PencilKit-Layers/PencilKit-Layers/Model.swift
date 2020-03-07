//
//  Model.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation
import PencilKit

struct Model {
    
    // MARK: - Properties -
    
    var drawings = [PKDrawing]()
    var drawingSnapshots = [UIImage]()
    
    let canvasViewThumbnailRenderer = DispatchQueue(label: "com.andrewfinke.layers.renderer.thumbnails", qos: .utility)
    let canvasViewDrawingRenderer = DispatchQueue(label: "com.andrewfinke.layers.renderer.drawing", qos: .userInitiated)
    
    // MARK: - Closuers -
    
    
//    /// Async save the new drawing for the thumbnails view
//    func generateThumbnailSnapshot() {
//        
//        canvasViewThumbnailRenderer.async {
//            drawing.image(from: canvasView.frame,
//                                     scale: UIScreen.main.scale)
//        }
//    }
//    
//    func generateLayerSnapshot() {
//        canvasViewLayerRenderer.sync {
//            drawing.image(from: canvasView.frame,
//                                     scale: UIScreen.main.scale)
//        }
//    }
    
}
