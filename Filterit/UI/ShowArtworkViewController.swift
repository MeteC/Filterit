//
//  ShowArtworkViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 24/08/2020.
//  Copyright © 2020 Mete Cakman. All rights reserved.
//

import UIKit
import SwifterSwift

/// View Controller for showing our library artwork. Has a hero transition like in ImageApprovalViewController (albeit simpler).
class ShowArtworkViewController: UIViewController {

    /// To be set during segue, to show the correct artwork
    private var artwork: ArtworkWrapper?
    
    /// And we'll store a weak reference to the underlying image view from which we're transitioning
    private weak var underlyingImageView: UIImageView?

    
    /// Use constraints to transition our artwork image
    @IBOutlet weak var artworkImageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintLeft: NSLayoutConstraint!
    
    /// Constraint for positioning of the details panel (stars, caption,..)
    @IBOutlet weak var detailsViewConstraintBottom: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundDarkenView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var captionView: UIView!
    @IBOutlet weak var detailsCaptionLabel: UILabel!
    
    // TODO: Pull out rating stars from their various places, make a separate RatingsView to reuse.
    @IBOutlet weak var ratingStar1: UIImageView!
    @IBOutlet weak var ratingStar2: UIImageView!
    @IBOutlet weak var ratingStar3: UIImageView!
    @IBOutlet weak var ratingStar4: UIImageView!
    @IBOutlet weak var ratingStar5: UIImageView!
    
    
    /// Call this during segue to set artwork correctly and prepare our appearance transition
    /// - Parameters:
    ///   - artwork: The artwork to show
    ///   - startFrame: The starting frame to transition in our image from. 
    ///   To be the frame of the same artwork view presented in the library, relative to the full screen window.
    public func prepare(with artwork: ArtworkWrapper, underlyingImageView: UIImageView) {
        self.artwork = artwork
        self.underlyingImageView = underlyingImageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let underlyingImageView = self.underlyingImageView, let artwork = self.artwork else {
            NSLog("Error - must call prepare(with...) before loading view!")
            return
        }
        
        // Do any additional setup after loading the view.
        self.artworkImageView.image = artwork.image
        
        // Figure out start frame relative to entire view
        let startFrame = self.view.convert(underlyingImageView.frame, from: underlyingImageView.superview)
        
        // calculate starting constraints from frame
        self.artworkImageConstraintTop.constant = startFrame.minY
        self.artworkImageConstraintLeft.constant = startFrame.minX
        self.artworkImageConstraintBottom.constant = self.view.frame.height - startFrame.maxY
        self.artworkImageConstraintRight.constant = self.view.frame.width - startFrame.maxX
        
        // details
        self.detailsCaptionLabel.text = artwork.caption
        
        // setup stars as in LibraryThumbCellViewModel
        let f = LibraryThumbCellViewModel.filledStar
        let e = LibraryThumbCellViewModel.emptyStar
        
        self.ratingStar1.image = artwork.rating > 0 ? f:e
        self.ratingStar2.image = artwork.rating > 1 ? f:e
        self.ratingStar3.image = artwork.rating > 2 ? f:e
        self.ratingStar4.image = artwork.rating > 3 ? f:e
        self.ratingStar5.image = artwork.rating > 4 ? f:e
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.layoutForFrameSize(UIScreen.main.bounds.size)
        
        // prepare for animations present in viewDidAppear
        self.backgroundDarkenView.alpha = 0
        self.captionView.alpha = 0
        self.ratingsView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animate in hero transition, and bring up details panel.
        // First hide the original artwork view while the hero transition is occurring, 
        // to prevent visibility of the backing layer.
        self.underlyingImageView?.isHidden = true
        
        // hide details panel - safe area height + detailsView frame height
        self.detailsViewConstraintBottom.constant = -(self.view.safeAreaInsets.bottom + self.ratingsView.frame.height)
        self.view.layoutIfNeeded()
        
        // Fade background to dark, then animate our artwork into full frame.
        // We'll also pull the star rating in from below with a little bounce, and fade the caption in
        let artworkInsetMargin: CGFloat = 8
        let detailsLowerMargin: CGFloat = 16
        
        // Timing values and calculations
        let backgroundFadeDuration = 0.2
        let heroTransitionDelay = backgroundFadeDuration / 2
        let heroTransitionDuration = 0.4
        let totalDuration = heroTransitionDelay + heroTransitionDuration
        
        UIView.animateKeyframes(withDuration: totalDuration, delay: 0, options: []) { 
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: backgroundFadeDuration / totalDuration) { 
                self.backgroundDarkenView.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: heroTransitionDelay / totalDuration, relativeDuration: heroTransitionDuration / totalDuration) { 
                // Full-screen image with inset margin
                self.artworkImageConstraintTop.constant = artworkInsetMargin
                self.artworkImageConstraintLeft.constant = artworkInsetMargin
                self.artworkImageConstraintBottom.constant = artworkInsetMargin
                self.artworkImageConstraintRight.constant = artworkInsetMargin
                self.view.layoutIfNeeded()
            }
        } completion: { (finished) in
            // on finish undo change to underlying view layers
            self.underlyingImageView?.isHidden = false
        }
        
        // Animate details views
        self.ratingsView.isHidden = false
        UIView.animate(withDuration: heroTransitionDuration, 
                       delay: heroTransitionDuration / 2, 
                       usingSpringWithDamping: 0.5, 
                       initialSpringVelocity: 1.0, 
                       options: [], 
                       animations: 
            { 
                self.detailsViewConstraintBottom.constant = detailsLowerMargin
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: heroTransitionDuration, delay: backgroundFadeDuration) { 
            self.captionView.alpha = 1
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.layoutForFrameSize(size)
    }
    
    /// Landscape size screens will hide the caption, portrait will show if caption isn't empty
    private func layoutForFrameSize(_ size: CGSize) {
        let isPortrait = size.aspectRatio <= 1
        let caption = self.artwork?.caption ?? ""
        self.captionView.isHidden = !isPortrait || caption.isEmpty
    }
    
    /// Just for debugging for now
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
}
