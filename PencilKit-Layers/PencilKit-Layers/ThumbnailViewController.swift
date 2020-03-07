//
//  ThumbnailViewController.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Combine
import UIKit

class ThumbnailViewController: UICollectionViewController {
    
    // MARK: - Properties -
    
    private var thumbnails = [UIImage]()
    private var activeThumbnailIndex = 0 {
        didSet {
            collectionView.reloadItems(at: [
                IndexPath(row: oldValue, section: 0),
                IndexPath(row: activeThumbnailIndex, section: 0)
            ])
            thumbnailIndexTapped.send(activeThumbnailIndex)
        }
    }
    
    let thumbnailIndexTapped = PassthroughSubject<Int, Never>()
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(ThumbnailCollectionViewCell.self,
                                      forCellWithReuseIdentifier: ThumbnailCollectionViewCell.reuseIdentifier)
    }
    
    func add(thumbnail: UIImage, at index: Int) {
        thumbnails.insert(thumbnail, at: index)
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.insertItems(at: [indexPath])
        
        if thumbnails.count == 1 {
            collectionView.cellForItem(at: indexPath)?.isSelected = true
        }
    }
    
    func update(thumbnail: UIImage, at index: Int) {
        thumbnails[index] = thumbnail
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionViewCell.reuseIdentifier, for: indexPath) as? ThumbnailCollectionViewCell else {
            fatalError()
        }
        cell.imageView.image = thumbnails[indexPath.row]
        return cell
    }

    // MARK: - UICollectionViewDelegate -

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activeThumbnailIndex = indexPath.row
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
