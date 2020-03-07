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
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Canvas"
        
        canvasView.frame = view.bounds
        canvasView.delegate = self
        view.addSubview(canvasView)
        
        let thumbnailCreated = model.thumbnailCreated
            .receive(on: RunLoop.main)
            .map { input -> (index: Int, thumbnail: UIImage) in
                self.createdLayer(at: input.index)
                return input
        }
  
        let thumbnailUpdated = model.thumbnailUpdated
            .receive(on: RunLoop.main)
            .merge(with: thumbnailCreated)
            .sink { index, thumbnail in
                print(thumbnail)
                print("updated")
        }
        
        cancellables.append(thumbnailUpdated)
        
        model.createLayer(at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureToolPicker()
    }
    
    private func createdLayer(at index: Int) {
        os_log("%{public}s: index: %{public}d", log: .controller, type: .info, #function, index)
    }
    
}

