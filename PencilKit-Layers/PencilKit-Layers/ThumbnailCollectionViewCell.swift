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
    
    static let reuseIdentifier = "Cell"
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // MARK: - Initalization -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        
        layer.borderColor = tintColor.cgColor
        layer.borderWidth = 4
        layer.cornerRadius = 4
        layer.cornerCurve = .continuous
    }
}

