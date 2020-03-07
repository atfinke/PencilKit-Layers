//
//  CanvasViewController+Buttons.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

extension CanvasViewController {
    
    func configureNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                           target: self,
                                                           action: #selector(share(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "sidebar.right"),
                                                            style: .plain, target: self,
                                                            action: #selector(toggleSidebar))
    }
    
    // MARK: - Actions -
    
    @objc
    private func share(sender: UIBarButtonItem) {
        let format = UIGraphicsImageRendererFormat()
        let renderer = UIGraphicsImageRenderer(bounds: canvasViewContainer.bounds, format: format)
        let image = renderer.image { _ in
            canvasViewContainer.drawHierarchy(in: canvasViewContainer.bounds, afterScreenUpdates: true)
        }
        
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = sender
        present(controller, animated: true, completion: nil)
    }
    
    @objc
    func toggleSidebar() {
        let width = Design.thumbnailWidthPadding + Design.thumbnailWidth
        let isShowing = thumbnailViewController.view.frame.maxX == view.frame.maxX &&
            thumbnailViewController.view.frame.width == width
        
        let frame: CGRect
        if isShowing {
            frame = CGRect(x: view.bounds.width,
            y: 0,
            width: width,
            height: view.bounds.height)
        } else {
            frame = CGRect(x: view.bounds.width - width,
            y: 0,
            width: width,
            height: view.bounds.height)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.85,
                       options: .allowAnimatedContent,
                       animations: {
            self.thumbnailViewController.view.frame = frame
        }, completion: nil)
    }
}
