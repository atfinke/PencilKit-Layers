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
            .sink { index, thumbnail in
                print(thumbnail)
        }
        
        cancellables.append(thumbnailCreated)
        
        model.createLayer(at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureToolPicker()
    }
    
}

