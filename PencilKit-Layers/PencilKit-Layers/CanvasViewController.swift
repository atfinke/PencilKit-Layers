//
//  CanvasViewController.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Combine
import UIKit
import PencilKit
import os.log

class CanvasViewController: UIViewController {
    
    // MARK: - Interface Properties -
    
    let canvasView: PKCanvasView = {
        let view = PKCanvasView()
        //        view.allowsFingerDrawing = false
        
        // Needed to have transparent canvas
        view.backgroundColor = .clear
        view.isOpaque = false
        return view
    }()
    
    var layers = [UIImageView]()
    var cancellables = [AnyCancellable]()
    
    let model = Model()
    let thumbnailViewController: ThumbnailViewController = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = Design.thumbnailSize
        layout.minimumLineSpacing = Design.thumbnailHeightPadding / 2
        layout.sectionInset = UIEdgeInsets(top: Design.thumbnailHeightPadding / 2,
                                           left: 0,
                                           bottom: Design.thumbnailHeightPadding / 2,
                                           right: 0)
        let controller = ThumbnailViewController(collectionViewLayout: layout)
        controller.collectionView.backgroundColor = .secondarySystemBackground
        return controller
    }()
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Canvas"
        
        canvasView.frame = view.bounds
        canvasView.delegate = self
        view.addSubview(canvasView)
        
        addChild(thumbnailViewController)
        thumbnailViewController.view.frame = CGRect(x: 0,
                                                    y: 0,
                                                    width: Design.thumbnailWidthPadding + Design.thumbnailWidth,
                                                    height: view.bounds.height)
        view.addSubview(thumbnailViewController.view)
        thumbnailViewController.didMove(toParent: self)
        
        configureModelSubscribers()
        model.createLayer(at: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureToolPicker()
    }
    
    // MARK: - Model Listeners -
    
    private func configureModelSubscribers() {
        let thumbnailCreated = model.thumbnailCreated
            .receive(on: RunLoop.main)
            .map { input -> (index: Int, thumbnail: UIImage) in
                self.created(thumbnail: input.thumbnail, at: input.index)
                return input
        }
        
        let thumbnailUpdated = model.thumbnailUpdated
            .receive(on: RunLoop.main)
            .merge(with: thumbnailCreated)
            .sink { index, thumbnail in
                self.updated(thumbnail: thumbnail, at: index)
        }
        
        let layerCreated = model.layerCreated
            .receive(on: RunLoop.main)
            .map { input -> (index: Int, snapshot: Model.LayerSnapshot) in
                self.created(snapshot: input.snapshot, at: input.index)
                return input
        }
        
        let layerUpdated = model.layerUpdated
            .receive(on: RunLoop.main)
            .merge(with: layerCreated)
            .sink { index, snapshot in
                self.updated(snapshot: snapshot, at: index)
        }
        
        cancellables = [thumbnailUpdated, layerUpdated]
    }
    
    private func created(snapshot: Model.LayerSnapshot, at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .controller, type: .info, #function, index)
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        layers.insert(imageView, at: index)
    }
    
    private func created(thumbnail: UIImage, at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .controller, type: .info, #function, index)
        thumbnailViewController.add(thumbnail: thumbnail, at: index)
    }
    
    private func updated(snapshot: Model.LayerSnapshot, at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .controller, type: .info, #function, index)
    }
    
    private func updated(thumbnail: UIImage, at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .controller, type: .info, #function, index)
        thumbnailViewController.update(thumbnail: thumbnail, at: index)
    }
    
}

