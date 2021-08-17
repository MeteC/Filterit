//
//  ImageApprovalViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 19/10/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit

/// A dialog style view controller that shows an image and allows us to accept or
/// cancel it's being chosen for further processing. "Hero" transition built in
/// (illusion to fly the image from another screen to it's full-size in this dialog)
class ImageApprovalViewController: UIViewController {

    // MARK: - Private and IB
    
    private var preparedForHeroTransition = false
    
    @IBOutlet weak var darkBackgroundView: UIView!
    @IBOutlet weak var dialogHolderView: UIView!
    @IBOutlet weak var heroTransitionImageView: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    
    // We'll use a thumbnail image view which will immediately have the image data, and
    // a full resolution image view which will pull the higher resolution image from
    // URL, fading out thumbImageView once it's ready
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var fullResImageView: UIImageView!
    
    // And this will hold both thumb and full resolution image views to fade them
    // in/out as a group
    @IBOutlet weak var imageHolderView: UIView!
    
    // Handle landscape and portrait switches well:
    @IBOutlet weak var dialogSidePortraitConstraint: NSLayoutConstraint!
    @IBOutlet weak var dialogSideLandscapeConstraint: NSLayoutConstraint!
    
    
    // MARK:- Setup
    
    /// Set this before showing vc, it's the image in question.
    /// 
    /// So this is basically being used as the ViewModel for this View
    /// Controller. Technically it's a "data model", but it's also very simple, and
    /// would be very easy to construct mock-ups just by manually creating an Image
    /// struct rather than decoding it from JSON - so it's got all right the properties
    /// of the ViewModel layer.
    public var image: Image?
    
    /// And the preloaded thumb image
    public var imageThumb: UIImage?
    
    /// We'll pass a hint back to whoever is waiting for `acceptBlock` to fire, as to
    /// whether they might expect the image to already be cached or not.
    private var isImageFullyCachedHint = false
    
    /// If you set this before showing the vc, we'll transition in using the "hero"
    /// transition. Otherwise we skip the transition.
    public var heroTransitionStartFrame: CGRect?
    
    /// Set this to change the accept button text. Default is "Apply Filter!"
    public var acceptButtonTitle: String? {
        didSet {
            self.acceptButton?.setTitle(acceptButtonTitle, for: .normal)
        }
    }
    
    /// Closure to run when accept button is pressed, gets provided the relevant image
    /// object plus a hint as to whether the image is already cached locally.
    public var acceptBlock: ((_ img: Image, _ isCachedHint: Bool) -> ())?
    
    /// Closure to run when cancel button is pressed
    public var cancelBlock: (() -> ())?
    
    /// Little convenience method for setting up the various required properties for a
    /// nice hero transition effect
    /// - Parameter image: the image in question
    /// - Parameter thumbnail: preloaded thumb image
    /// - Parameter startFrame: starting frame for the hero transition
    /// - Parameter acceptButtonTitle: optional title to rename the accept button
    public func preConfigureForHeroTransition(with image: Image, 
                                              thumbnail: UIImage?, 
                                              startFrame: CGRect, 
                                              acceptButtonTitle: String?) {
        self.image = image
        self.imageThumb = thumbnail
        self.heroTransitionStartFrame = startFrame
        if let newTitle = acceptButtonTitle { self.acceptButtonTitle = newTitle }
    }
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        thumbImageView.image = imageThumb
        
        // set accept button title now if it's been pre-set
        if let acceptButtonTitle = self.acceptButtonTitle {
            self.acceptButton.setTitle(acceptButtonTitle, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // this will switch our image appearance from thumbnail quality to final image
        // quality once it's downloaded
        fullResImageView.moa.url = image?.url 
        fullResImageView.moa.onSuccess = { image in
            NSLog("Fading in full res image!")
            self.isImageFullyCachedHint = true
            
            UIView.animate(withDuration: 0.4, delay: 1.0, animations: { 
                self.thumbImageView.alpha = 0
            }, completion: nil)
            return image
        }
        
        // Here's the spot to prepare for hero animation if required
        if let startFrame = self.heroTransitionStartFrame {
            self.prepHeroTransition(from: startFrame)
        }
        
        self.selectCorrectConstraint(for: self.view.bounds.size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if preparedForHeroTransition {
            self.startHeroTransition()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.selectCorrectConstraint(for: size)
    }
    
    /// Select the appropriate constraint for "portrait" or "landscape" mode layouts
    /// (just based on aspect ratio of screen)
    /// - Parameter size: super view size
    private func selectCorrectConstraint(for size: CGSize) {
        if size.width <= size.height {
            // Portrait (or 1:1)
            self.dialogSidePortraitConstraint.priority = 999
            self.dialogSideLandscapeConstraint.priority = 1
        } else {
            // Landscape
            self.dialogSidePortraitConstraint.priority = 1
            self.dialogSideLandscapeConstraint.priority = 999
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressCancel(_ sender: Any) {
        self.cancelBlock?()
    }
    
    @IBAction func pressAccept(_ sender: Any) {
        if let image = self.image {
            self.acceptBlock?(image, isImageFullyCachedHint)
        } else {
            NSLog("Warning - pressed accept for nil image")
        }
    }
    
    
    // MARK:- Hero Transition
    
    
    /// The hero transition:
    /// 
    /// 1. Start with the VC transparent on top, render the thumbnail perfectly on top
    /// of it's start frame so it should look like nothing has changed.
    /// 
    /// 2. Animate the location and size of the image to it's final frame
    /// (imageView.frame as described in the storyboard.)
    /// 
    /// 3. At the same time (maybe with slight delay?) fade in the dialog backgrounds -
    /// the dark translucency of the background view and the white dialog frame +
    /// buttons.
    /// 
    /// Meanwhile, we're showing a thumbnail - we can use this opportunity to pull the
    /// full size image and, once we have it, update the image with the higher
    /// resolution version (cross fading?) Note this step is taken care of by how we set
    /// up our imageView in our view controller lifecycle methods above
    private func prepHeroTransition(from startFrame: CGRect) {
        // initial conditions
        self.heroTransitionImageView.image = imageThumb
        self.heroTransitionImageView.frame = startFrame
        self.darkBackgroundView.alpha = 0.0
        self.imageHolderView.alpha = 0.0
        self.preparedForHeroTransition = true
    }
    
    private func startHeroTransition() {
        
        let transitionTime = 0.7
        let finalImageFrame: CGRect = self.thumbImageView.convert(self.thumbImageView.bounds, to: nil)
        
        // animations
        UIView.animateKeyframes(withDuration: transitionTime, delay: 0.0, options: [], animations: { 
            
            // movement keyframe
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) { 
                self.heroTransitionImageView.frame = finalImageFrame
            }
            
            // fade in full imageView underneath
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) { 
                self.imageHolderView.alpha = 1.0 
            }
            
            // fade out hero view (after fade in beneath so there's no weird cross-flash)
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) { 
                self.heroTransitionImageView.alpha = 0
            }
            
            // overlapping, bring in the dialog frame
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) { 
                self.darkBackgroundView.alpha = 1.0
            }
        }) { (completed) in
            // done!
        }
    }

}
