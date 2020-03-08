//
//  ThumbnailViewController+DND.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

extension ThumbnailViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    // MARK: - UICollectionViewDragDelegate -
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: indexPath.row.description as NSString)
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    // MARK: - UICollectionViewDropDelegate -
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if session.localDragSession == nil {
            return UICollectionViewDropProposal(operation: .forbidden)
        } else {
            return UICollectionViewDropProposal(operation: .move)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destination = coordinator.destinationIndexPath,
            let origin = coordinator.items.first?.sourceIndexPath else {
                return
        }
        thumbnailAction.send(.reordered(index: origin.row, destination: destination.row))
    }
    
}
