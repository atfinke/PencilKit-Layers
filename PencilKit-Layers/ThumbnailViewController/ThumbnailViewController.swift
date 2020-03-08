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
    
    // MARK: - Types -
    
    enum Action {
        case tapped(index: Int), deleted(index: Int), visiblity(index: Int), reordered(index: Int, destination: Int), added
    }
    
    // MARK: - Properties -
    
    private var thumbnails = [Model.Thumbnail]()
    private var activeThumbnailIndex = 0 {
        didSet {
            thumbnailAction.send(.tapped(index: activeThumbnailIndex))
        }
    }
    
    private var needsToDeselectInitalLayer = true
    let thumbnailAction = PassthroughSubject<Action, Never>()
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("unexpected layout")
        }
        layout.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
        
        collectionView?.register(ThumbnailCollectionViewCell.self,
                                 forCellWithReuseIdentifier: ThumbnailCollectionViewCell.reuseIdentifier)
        collectionView?.register(ThumbnailAddButtonView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                 withReuseIdentifier: ThumbnailAddButtonView.reuseIdentifier)
        
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    func add(thumbnail: Model.Thumbnail, at index: Int) {
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
    
    func remove(at index: Int, nowActive activeIndex: Int) {
        thumbnails.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        let activeIndexPath = IndexPath(row: activeIndex, section: 0)
        UIView.performWithoutAnimation {
            collectionView.deleteItems(at: [indexPath])
            collectionView.selectItem(at: activeIndexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }
    
    func update(thumbnail: Model.Thumbnail, at index: Int) {
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
    
    func reorderItem(at origin: Int, to destination: Int, isActive: Bool) {
        if destination == -1 {
            let indexPath = IndexPath(row: origin, section: 0)
            let isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath)
            
            self.thumbnails.remove(at: origin)
            collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
                if isSelected ?? false {
                    if origin == 0 {
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                    } else {
                        self.collectionView.selectItem(at: IndexPath(row: origin - 1, section: 0), animated: false, scrollPosition: .centeredVertically)
                    }
                }
            }, completion: nil)
            return
        }
        
        let image = thumbnails.remove(at: origin)
        thumbnails.insert(image, at: destination)
        let originIndexPath = IndexPath(row: origin, section: 0)
        let destinationIndexPath = IndexPath(row: destination, section: 0)
        
        UIView.performWithoutAnimation {
            self.collectionView.moveItem(at: originIndexPath, to: destinationIndexPath)
            if isActive {
                collectionView.selectItem(at: destinationIndexPath,
                                          animated: false,
                                          scrollPosition: .centeredVertically)
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
        let thumbnail = thumbnails[indexPath.row]
        cell.imageView.image = thumbnail.image
        cell.eyeImageViewContainer.isHidden = thumbnail.isVisible
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else {
            fatalError("unexpected view kind: \(kind)")
        }
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: ThumbnailAddButtonView.reuseIdentifier, for: indexPath) as? ThumbnailAddButtonView else {
                                                                            fatalError("failed to dequeue")
        }
        view.tapped = {
            self.thumbnailAction.send(.added)
        }
        return view
    }
    
    // MARK: - UICollectionViewDelegate -
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activeThumbnailIndex = indexPath.row
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            var children = [UIAction]()
            if self.thumbnails[indexPath.row].isVisible {
                let hide = UIAction(title: "Hide", image: UIImage(systemName: "eye.slash")) { _ in
                    self.thumbnailAction.send(.visiblity(index: indexPath.row))
                }
                children.append(hide)
            } else {
                let show = UIAction(title: "Show", image: UIImage(systemName: "eye")) { _ in
                    self.thumbnailAction.send(.visiblity(index: indexPath.row))
                }
                children.append(show)
            }
            
            if self.thumbnails.count > 1 {
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
                    self.thumbnailAction.send(.deleted(index: indexPath.row))
                }
                children.append(delete)
            }
            return UIMenu(title: "", children: children)
        }
    }
    
}
