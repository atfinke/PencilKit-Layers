//
//  CanvasViewController+PencilKit.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
import PencilKit

extension CanvasViewController: PKCanvasViewDelegate {
    
    func configureToolPicker() {
        guard let window = view.window,
            let toolPicker = PKToolPicker.shared(for: window) else {
                fatalError("Couldn't get window")
        }
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    // MARK: - PKCanvasViewDelegate -
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        model.generateThumbnailSnapshot()
    }
}

