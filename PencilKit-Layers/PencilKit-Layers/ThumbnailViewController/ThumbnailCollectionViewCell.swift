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
    
    let eyeImageViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.quaternarySystemFill.withAlphaComponent(0.25)
        view.isHidden = true
        return view
    }()
    
    private let eyeImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor.label
        view.image = UIImage(systemName: "eye.slash.fill")
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
        
        eyeImageViewContainer.addSubview(eyeImageView)
        addSubview(eyeImageViewContainer)
        
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
        
        eyeImageViewContainer.frame = bounds
        eyeImageView.center = eyeImageViewContainer.center
    }
}

