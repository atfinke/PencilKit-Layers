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
    
    let canvasViewsContainer = UIView()
    private var layers = [PKCanvasView]()
    private lazy var toolPicker: PKToolPicker = {
        guard let window = view.window, let toolPicker = PKToolPicker.shared(for: window) else {
            fatalError("Couldn't get window")
        }
        return toolPicker
    }()
    
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
    
    
    // MARK: - Other Properties -
    
    private var cancellables = [AnyCancellable]()
    let model = Model()
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PencilKit Layers Exploration"
        configureCanvasViewsContainer()
        configureThumbnailViewController()
        
        configureModelSubscribers()
        model.createLayer()
        
        configureNavigationItem()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // MARK: - Model Listeners -
    
    private func configureModelSubscribers() {
        let thumbnailUpdate = model.thumbnailUpdate
            .receive(on: RunLoop.main)
            .sink(receiveValue: { update in
                switch update {
                case .created(let index, let thumbnail):
                    self.created(thumbnail: thumbnail, at: index)
                    self.updated(thumbnail: thumbnail, at: index)
                case .updated(let index, let thumbnail):
                    self.updated(thumbnail: thumbnail, at: index)
                case .reordered(let origin, let destination, let isActive):
                    self.thumbnailViewController.reorderItem(at: origin, to: destination, isActive: isActive)
                }
            })
        
        let layerUpdate = model.layerUpdate
            .receive(on: RunLoop.main)
            .sink { action in
                switch action {
                case .created(let index):
                    let layer = self.createNewLayer()
                    
                    self.layers.insert(layer, at: index)
                    if self.layers.count == 1 {
                        self.layers.first?.isUserInteractionEnabled = true
                        self.layers.first?.becomeFirstResponder()
                        self.canvasViewsContainer.addSubview(layer)
                    } else if index == 0 {
                        self.canvasViewsContainer.bringSubviewToFront(layer)
                    } else {
                        self.canvasViewsContainer.insertSubview(layer, belowSubview: self.layers[index - 1])
                    }
                case .active(let previous, let new):
                    if let previous = previous {
                        self.layers[previous].isUserInteractionEnabled = false
                        self.layers[previous].resignFirstResponder()
                    }
                    self.layers[new].isUserInteractionEnabled = true
                    self.layers[new].becomeFirstResponder()
                case .reordered(let origin, let destination):
                    if destination == -1 {
                        self.layers[origin].removeFromSuperview()
                        self.layers.remove(at: origin)
                        return
                    }
                    
                    let layer = self.layers.remove(at: origin)
                    self.layers.insert(layer, at: destination)
                    if destination == 0 {
                        self.canvasViewsContainer.bringSubviewToFront(layer)
                    } else {
                        self.canvasViewsContainer.insertSubview(layer, belowSubview: self.layers[destination - 1])
                    }
                }
        }
        
        cancellables.append(contentsOf: [thumbnailUpdate, layerUpdate])
    }
    
    private func created(thumbnail: Model.Thumbnail, at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .controller, type: .info, #function, index)
        thumbnailViewController.add(thumbnail: thumbnail, at: index)
    }
    
    private func updated(thumbnail: Model.Thumbnail, at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .controller, type: .info, #function, index)
        thumbnailViewController.update(thumbnail: thumbnail, at: index)
        layers[index].isHidden = !thumbnail.isVisible
    }
    
    // MARK: - Other -
    
    func configureThumbnailViewController() {
        addChild(thumbnailViewController)
        UIView.performWithoutAnimation {
            self.toggleSidebar()
        }
        view.addSubview(thumbnailViewController.view)
        thumbnailViewController.didMove(toParent: self)
        
        let thumbnailAction = thumbnailViewController.thumbnailAction.sink { action in
            switch action {
            case .tapped(let index):
                self.model.selectLayer(at: index)
            case .deleted(let index):
                self.model.deleteItem(at: index)
            case .visiblity(let index):
                self.model.toggleItemVisiblity(at: index)
            case .reordered(let origin, let destination):
                self.model.reorderItem(at: origin, to: destination)
            case .added:
                self.model.createLayer()
            }
        }
        cancellables.append(thumbnailAction)
    }
    
    func createNewLayer() -> PKCanvasView {
        let canvasView = PKCanvasView(frame: canvasViewsContainer.bounds)
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.delegate = self
        canvasView.isUserInteractionEnabled = false
        canvasView.allowsFingerDrawing = false
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        return canvasView
    }
    
}
