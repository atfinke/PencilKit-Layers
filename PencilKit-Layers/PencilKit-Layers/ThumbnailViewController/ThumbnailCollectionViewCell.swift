//
//  ThumbnailCollectionViewCell.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties -
    
    static let reuseIdentifier = "ThumbnailCollectionViewCell"
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemBackground
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - Initalization -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(imageView)
        layer.borderColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        let borderWidth: CGFloat = 4
        layer.borderWidth = borderWidth
        layer.cornerRadius = 6
        layer.cornerCurve = .continuous
        layer.borderColor = (isSelected ? tintColor : .clear)?.cgColor
        
        imageView.frame = bounds.insetBy(dx: borderWidth, dy: borderWidth)
    }
}

