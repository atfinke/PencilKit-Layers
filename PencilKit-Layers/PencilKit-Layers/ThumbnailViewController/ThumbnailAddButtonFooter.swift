//
//  ThumbnailAddButtonFooter.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

class ThumbnailAddButtonFooter: UICollectionReusableView {
    
    // MARK: - Properties -
    
    static let reuseIdentifier = "ThumbnailAddButtonFooter"
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = UIColor.secondaryLabel
        view.image = UIImage(systemName: "plus.circle.fill")
        return view
    }()
    
    private let button = UIButton()
    var tapped: (() -> Void)?
    
    // MARK: - Initalization -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(button)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = Design.thumbnailAddButtonSize
        imageView.frame = CGRect(origin: CGPoint(x: bounds.width / 2 - size.width / 2,
                                                 y: bounds.height / 2 - size.height / 2),
                                 size: size)
        button.frame = bounds
    }

    // MARK: - Touches -
    
    @objc
    private func buttonTapped() {
        tapped?()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: Design.thumbnailAddButtonScaleDuration,
                       delay: 0,
                       usingSpringWithDamping: Design.thumbnailAddButtonScaleDamping,
                       initialSpringVelocity: Design.thumbnailAddButtonScaleVelocity,
                       options: .allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: Design.thumbnailAddButtonScaleFactor,
                                                           y: Design.thumbnailAddButtonScaleFactor)
        }, completion: { _ in

        })
    }

    private func touchesEnded() {
        UIView.animate(withDuration: Design.thumbnailAddButtonScaleDuration,
                       delay: 0,
                       usingSpringWithDamping: Design.thumbnailAddButtonScaleDamping,
                       initialSpringVelocity: Design.thumbnailAddButtonScaleVelocity,
                       options: .allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { _ in

        })
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEnded()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesEnded()
    }
}
