//
//  ShowArtworkViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 24/08/2020.
//  Copyright © 2020 Mete Cakman. All rights reserved.
//

import UIKit

/// View Controller for showing our library artwork. Has a hero transition like in ImageApprovalViewController (albeit simpler).
class ShowArtworkViewController: UIViewController {

    /// To be set during segue, to show the correct artwork
    private var artwork: ArtworkWrapper?
    public var heroTransitionStartFrame: CGRect?
    
    /// Use constraints to transition our artwork image
    @IBOutlet weak var artworkImageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintLeft: NSLayoutConstraint!
    
    /// Constraint for positioning of the details panel (stars, caption,..)
    @IBOutlet weak var detailsViewConstraintBottom: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundDarkenView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var detailsView: UIView!
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
    public func prepare(with artwork: ArtworkWrapper, transitionFrom startFrame: CGRect) {
        self.artwork = artwork
        self.heroTransitionStartFrame = startFrame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let startFrame = heroTransitionStartFrame, let artwork = self.artwork else {
            NSLog("Error - must call prepare(with...) before loading view!")
            return
        }
        
        // Do any additional setup after loading the view.
        self.artworkImageView.image = artwork.image
        
        // calculate starting constraints from frame
        self.artworkImageConstraintTop.constant = startFrame.minY
        self.artworkImageConstraintLeft.constant = startFrame.minX
        self.artworkImageConstraintBottom.constant = self.view.frame.height - startFrame.maxY
        self.artworkImageConstraintRight.constant = self.view.frame.width - startFrame.maxX
        
        // hide details panel
        self.detailsViewConstraintBottom.constant = -self.detailsView.frame.height
        
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fade background to dark, while animating our artwork into full frame.
        // We'll also pull the star rating and caption in from below with a little bounce
        self.backgroundDarkenView.alpha = 0
        
        let transitionDuration = 0.5
        
        UIView.animate(withDuration: transitionDuration) { 
            self.backgroundDarkenView.alpha = 1
            
            // Full-screen image with inset margin
            let insetMargin: CGFloat = 8
            
            self.artworkImageConstraintTop.constant = insetMargin
            self.artworkImageConstraintLeft.constant = insetMargin
            self.artworkImageConstraintBottom.constant = insetMargin
            self.artworkImageConstraintRight.constant = insetMargin
            
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: transitionDuration*2, 
                       delay: 0, 
                       usingSpringWithDamping: 0.5, 
                       initialSpringVelocity: 0, 
                       options: [], 
                       animations: 
            { 
                self.detailsViewConstraintBottom.constant = 25 // TODO: take safe area into account
                self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    /// Just for debugging for now
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
}
