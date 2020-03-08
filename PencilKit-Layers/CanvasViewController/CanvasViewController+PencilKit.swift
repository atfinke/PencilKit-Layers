//
//  CanvasViewController+PencilKit.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
import PencilKit
import os.log

extension CanvasViewController: PKCanvasViewDelegate {
    
    // MARK: - Interface Configuration -
    
    func configureCanvasViewsContainer() {
        canvasViewsContainer.frame = view.bounds
        view.addSubview(canvasViewsContainer)
    }

    // MARK: - PKCanvasViewDelegate -
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        os_log("%{public}s: called", log: .controller, type: .info, #function)
        model.updated(drawing: canvasView.drawing)
    }
}

