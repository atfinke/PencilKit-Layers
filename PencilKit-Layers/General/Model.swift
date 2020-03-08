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
    
    class Thumbnail {
        var image: UIImage
        var isVisible: Bool
        
        init(_ image: UIImage, isVisible: Bool) {
            self.image = image
            self.isVisible = isVisible
        }
    }
    
    enum ThumbnailUpdate {
        case created(index: Int, thumbnail: Thumbnail), updated(index: Int, thumbnail: Thumbnail), reordered(origin: Int, destination: Int, isActive: Bool)
    }
    
    enum LayerUpdate {
        case created(index: Int), active(previous: Int?, new: Int), reordered(origin: Int, destination: Int)
    }
    
    // MARK: - Properties -
    
    var activeDrawingIndex = 0 {
        didSet {
            os_log("%{public}s: now: %{public}d", log: .model, type: .info, #function, activeDrawingIndex)
        }
    }
    
    private(set) var thumbnails = [Thumbnail]()
    private let canvasViewThumbnailRenderer = DispatchQueue(label: "com.andrewfinke.layers.renderer", qos: .utility)
    
    // MARK: - Publishers -
    
    let thumbnailUpdate = PassthroughSubject<ThumbnailUpdate, Never>()
    let layerUpdate = PassthroughSubject<LayerUpdate, Never>()
    
    // MARK: - Layer State -
    
    func createLayer() {
        os_log("%{public}s: called", log: .model, type: .info, #function)
        
        let index = thumbnails.count
        let thumbnail = Thumbnail(UIImage(), isVisible: true)
        thumbnails.insert(thumbnail, at: index)

        layerUpdate.send(.created(index: index))
        thumbnailUpdate.send(.created(index: index, thumbnail: thumbnail))
    }
    
    func selectLayer(at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .model, type: .info, #function, index)
        let previous = activeDrawingIndex
        activeDrawingIndex = index
        layerUpdate.send(.active(previous: previous, new: index))
    }
    
    func reorderItem(at origin: Int, to destination: Int) {
        os_log("%{public}s: origin: %{public}d, origin: %{public}d", log: .model, type: .info, #function, origin, destination)
        
        let isActive = origin == activeDrawingIndex
        let thumbnail = thumbnails.remove(at: origin)

        thumbnails.insert(thumbnail, at: destination)
        thumbnailUpdate.send(.reordered(origin: origin, destination: destination, isActive: isActive))
        layerUpdate.send(.reordered(origin: origin, destination: destination))
        
        if isActive {
            activeDrawingIndex = destination
        } else if origin > activeDrawingIndex && destination <= activeDrawingIndex {
            activeDrawingIndex += 1
        } else if origin < activeDrawingIndex && destination >= activeDrawingIndex {
            activeDrawingIndex -= 1
        }
    }
    
    func deleteItem(at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .model, type: .info, #function, index)
        assert(thumbnails.count > 1)
        
        thumbnails.remove(at: index)
        thumbnailUpdate.send(.reordered(origin: index, destination: -1, isActive: false))
        layerUpdate.send(.reordered(origin: index, destination: -1))

        if activeDrawingIndex == index {
            if index == 0 {
                layerUpdate.send(.active(previous: nil, new: 0))
            } else {
                layerUpdate.send(.active(previous: nil, new: index - 1))
            }
        } else if activeDrawingIndex > index {
            activeDrawingIndex -= 1
        }
    }
    
    func toggleItemVisiblity(at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .model, type: .info, #function, index)
        thumbnails[index].isVisible.toggle()
        thumbnailUpdate.send(.updated(index: index, thumbnail: thumbnails[index]))
    }
    
    func updated(drawing: PKDrawing) {
        os_log("%{public}s: called", log: .model, type: .info, #function)
        generateThumbnailSnapshot(drawing: drawing)
    }
    
    // MARK: - Image Generation -
    
    private func generateThumbnailSnapshot(drawing: PKDrawing) {
        os_log("%{public}s: called", log: .model, type: .info, #function)
        assert(Thread.isMainThread)
        
        let drawingIndex = activeDrawingIndex
        let thumbnailCaptureSize = UIScreen.main.bounds
        let scale = Design.thumbnailWidth / thumbnailCaptureSize.width
        
        canvasViewThumbnailRenderer.async {
            let image = drawing.image(from: thumbnailCaptureSize, scale: scale)
            
            os_log("%{public}s: size: %{public}s, scale: %{public}.2f", log: .model, type: .info, #function, thumbnailCaptureSize.debugDescription, scale)
            
            self.thumbnails[drawingIndex].image = image
            self.thumbnailUpdate.send(.updated(index: drawingIndex, thumbnail: self.thumbnails[drawingIndex]))
        }
    }
    
}
