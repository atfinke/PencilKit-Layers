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
            thumbnailIndexTapped.send(activeThumbnailIndex)
        }
    }
    
    private var needsToDeselectInitalLayer = true
    
    let thumbnailIndexTapped = PassthroughSubject<Int, Never>()
    let thumbnailReordered = PassthroughSubject<(origin: Int, destination: Int), Never>()
    let thumbnailAddButtonTapped = PassthroughSubject<Bool, Never>()
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("unexpected layout")
        }
        layout.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)

        collectionView?.register(ThumbnailCollectionViewCell.self,
                                      forCellWithReuseIdentifier: ThumbnailCollectionViewCell.reuseIdentifier)
        collectionView?.register(ThumbnailAddButtonFooter.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                 withReuseIdentifier: ThumbnailAddButtonFooter.reuseIdentifier)
        
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    func add(thumbnail: UIImage, at index: Int) {
        thumbnails.insert(thumbnail, at: index)
        let indexPath = IndexPath(row: index, section: 0)
        if thumbnails.count == 1 {
            UIView.performWithoutAnimation {
                collectionView.insertItems(at: [indexPath])
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
            }
        } else {
            collectionView.insertItems(at: [indexPath])
        }
    }
    
    func update(thumbnail: UIImage, at index: Int) {
        thumbnails[index] = thumbnail
        let indexPath = IndexPath(row: index, section: 0)
        let isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath)
        
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: [indexPath])
            if isSelected ?? false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
            }
        }
    }
    
    func reorderItem(at origin: Int, to destination: Int) {
        let image = thumbnails.remove(at: origin)
        thumbnails.insert(image, at: destination)
        let originIndexPath = IndexPath(row: origin, section: 0)
        let destinationIndexPath = IndexPath(row: destination, section: 0)
        let isSelected = collectionView.indexPathsForSelectedItems?.contains(originIndexPath)
        
        UIView.performWithoutAnimation {
            self.collectionView.moveItem(at: originIndexPath, to: destinationIndexPath)
            if isSelected ?? false {
                collectionView.selectItem(at: destinationIndexPath, animated: false, scrollPosition: .centeredVertically)
            }
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
            fatalError("failed to dequeue")
        }
        cell.imageView.image = thumbnails[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else {
            fatalError("unexpected view kind: \(kind)")
        }
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: ThumbnailAddButtonFooter.reuseIdentifier, for: indexPath) as? ThumbnailAddButtonFooter else {
                                                                            fatalError("failed to dequeue")
        }
        header.tapped = {
            self.thumbnailAddButtonTapped.send(true)
        }
        return header
    }

    // MARK: - UICollectionViewDelegate -

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activeThumbnailIndex = indexPath.row
    }


}
