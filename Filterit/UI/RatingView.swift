//
//  RatingView.swift
//  Filterit
//
//  Created by Mete Cakman on 11/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit

/// Factoring out a common 5-star rating widget.
/// It's not a UI control - it just reflects a rating value without interaction.
/// Designable for Interface Builder verification
@IBDesignable
class RatingView: UIView {

    // We'll render system images for our stars
    private var filledStar: UIImage
    private var emptyStar: UIImage
    
    /// Spacing to apply between the stars
    @IBInspectable var spacing: CGFloat = 8.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The rating, a value from 0 to 5 (values outside this range are ignored)
    @IBInspectable var rating: Int = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder: NSCoder) {
        filledStar = UIImage(systemName: "star.fill") ?? UIImage()
        emptyStar = UIImage(systemName: "star") ?? UIImage()
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        filledStar = UIImage(systemName: "star.fill") ?? UIImage()
        emptyStar = UIImage(systemName: "star") ?? UIImage()
        super.init(frame: frame)
    }
    
    
    override func draw(_ rect: CGRect) {
        // Calculate width of each star to fit in the draw rect.
        // We'll keep aspect ratio = 1 and center vertically within the rect
        let starWidth = ((rect.width - (4 * spacing)) / 5)
        let starHeight = starWidth
        let starY = (rect.height - starHeight) / 2
        var starX: CGFloat = 0
        
        for i in 0..<5 {
            let star = rating > i ? filledStar : emptyStar
            let starRect = CGRect(x: starX, y: starY, width: starWidth, height: starHeight)
            star.withTintColor(tintColor).draw(in: starRect)
            starX += starWidth + spacing
        }
    }
}
