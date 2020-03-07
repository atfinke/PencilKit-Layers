//
//  Model.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Combine
import Foundation
import PencilKit
import os.log

class Model {
    
    // MARK: - Types -
    
    struct LayerSnapshot {
        let bounds: CGRect
        let image: UIImage
    }
    
    // MARK: - Properties -
    
    var activeDrawingIndex = 0 {
        didSet {
            os_log("%{public}s: now: %{public}d", log: .model, type: .info, #function, activeDrawingIndex)
        }
    }
    var activeDrawing: PKDrawing {
        if activeDrawingIndex < drawings.count {
            return drawings[activeDrawingIndex]
        } else {
            fatalError("Tried to get drawing at index \(activeDrawingIndex), but only \(drawings.count) drawing(s)")
        }
    }
    
    private(set) var drawings = [PKDrawing]()
    private(set) var drawingLayerSnapshots = [LayerSnapshot]()
    private(set) var drawingThumbnailSnapshots = [UIImage]()
    
    private let canvasViewLayerRenderer = DispatchQueue(label: "com.andrewfinke.layers.renderer.layer", qos: .userInitiated)
    private let canvasViewThumbnailRenderer = DispatchQueue(label: "com.andrewfinke.layers.renderer.thumbnails", qos: .utility)
    
    // MARK: - Closuers -
    
    let thumbnailCreated = PassthroughSubject<(index: Int, thumbnail: UIImage), Never>()
    let layerCreated = PassthroughSubject<(index: Int, snapshot: LayerSnapshot), Never>()
    
    let thumbnailUpdated = PassthroughSubject<(index: Int, thumbnail: UIImage), Never>()
    let layerUpdated = PassthroughSubject<(index: Int, snapshot: LayerSnapshot), Never>()
    
    // MARK: - Layer State -
    
    func createLayer(at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .model, type: .info, #function, index)
        
        if index <= drawings.count {
            let thumbnail = UIImage()
            let layer = LayerSnapshot(bounds: .zero, image: thumbnail)
            
            drawings.insert(PKDrawing(), at: index)
            drawingThumbnailSnapshots.insert(thumbnail, at: index)
            drawingLayerSnapshots.insert(layer, at: index)
            
            thumbnailCreated.send((index, thumbnail))
            layerCreated.send((index, layer))
        } else {
            fatalError("Invalid index \(index), only have \(drawings.count) layers")
        }
    }
    
    
    // MARK: - Image Generation -
    
    func generateThumbnailSnapshot() {
        os_log("%{public}s: called", log: .model, type: .info, #function)
        assert(Thread.isMainThread)
        
        let drawing = activeDrawing
        let drawingIndex = activeDrawingIndex
        
        let thumbnailCaptureSize = UIScreen.main.bounds
        let scale = Design.thumbnailWidth / thumbnailCaptureSize.width
        
        canvasViewThumbnailRenderer.async {
            let image = drawing.image(from: thumbnailCaptureSize, scale: scale)
            
            os_log("%{public}s: size: %{public}s, scale: %{public}.2f", log: .model, type: .info, #function, thumbnailCaptureSize.debugDescription, scale)
            
            self.drawingThumbnailSnapshots[drawingIndex] = image
            self.thumbnailUpdated.send((drawingIndex, image))
        }
    }
    
    func generateLayerSnapshot() {
        os_log("%{public}s: called", log: .model, type: .info, #function)
        
        assert(Thread.isMainThread)
        
        let drawing = activeDrawing
        let drawingIndex = activeDrawingIndex
        
        let thumbnailCaptureSize = UIScreen.main.bounds
        let scale = Design.thumbnailWidth / thumbnailCaptureSize.width
        
        canvasViewLayerRenderer.async {
            let bounds = drawing.bounds
            let image =  drawing.image(from: bounds, scale: scale)
            let snapshot = LayerSnapshot(bounds: bounds, image: image)
            
            os_log("%{public}s: size: %{public}s, scale: %{public}.2f", log: .model, type: .info, #function, thumbnailCaptureSize.debugDescription, scale)
            
            self.drawingLayerSnapshots[drawingIndex] = snapshot
            self.layerUpdated.send((drawingIndex, snapshot))
        }
    }
    
}
