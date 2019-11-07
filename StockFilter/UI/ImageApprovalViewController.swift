//
//  ImageApprovalViewController.swift
//  StockFilter
//
//  Created by Mete Cakman on 19/10/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit

/// A dialog style view controller that shows an image and allows us to accept or cancel it's being chosen for further processing. "Hero" transition built in (illusion to fly the image from another screen to it's full-size in this dialog)
class ImageApprovalViewController: UIViewController {

    // MARK: - Private and IB
    
    private var preparedForHeroTransition = false
    
    @IBOutlet weak var darkBackgroundView: UIView!
    @IBOutlet weak var dialogHolderView: UIView!
    @IBOutlet weak var heroTransitionImageView: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    
    // We'll use a thumbnail image view which will immediately have the image data, and a full resolution image view which will pull the higher resolution image from URL, fading out thumbImageView once it's ready
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var fullResImageView: UIImageView!
    
    // And this will hold both thumb and full resolution image views to fade them in/out as a group
    @IBOutlet weak var imageHolderView: UIView!
    
    // MARK:- Setup
    
    /// Set this before showing vc, it's the image in question
    public var image: Image?
    
    /// And the preloaded thumb image
    public var imageThumb: UIImage?
    
    /// If you set this before showing the vc, we'll transition in using the "hero" transition. Otherwise we skip the transition.
    public var heroTransitionStartFrame: CGRect?
    
    /// Set this to change the accept button text. Default is "Apply Filter!"
    public var acceptButtonTitle: String? {
        didSet {
            self.acceptButton?.setTitle(acceptButtonTitle, for: .normal)
        }
    }
    
    /// Closure to run when accept button is pressed, gets provided the relevant image object
    public var acceptBlock: ((Image) -> ())?
    
    /// Little convenience method for setting up the various required properties for a nice hero transition effect
    /// - Parameter image: the image in question
    /// - Parameter thumbnail: preloaded thumb image
    /// - Parameter startFrame: starting frame for the hero transition
    /// - Parameter acceptButtonTitle: optional title to rename the accept button
    /// - Parameter acceptBlock: required closure that runs when accept button is tapped
    public func preConfigureForHeroTransition(with image: Image, 
                                              thumbnail: UIImage?, 
                                              startFrame: CGRect, 
                                              acceptButtonTitle: String?, 
                                              acceptBlock: @escaping ((Image) -> ())) {
        self.image = image
        self.imageThumb = thumbnail
        self.heroTransitionStartFrame = startFrame
        if let newTitle = acceptButtonTitle { self.acceptButtonTitle = newTitle }
        self.acceptBlock = acceptBlock
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
        
        // this will switch our image appearance from thumbnail quality to final image quality once it's downloaded
        fullResImageView.moa.url = image?.url 
        fullResImageView.moa.onSuccess = { image in
            NSLog("Fading in full res image!")
            UIView.animate(withDuration: 0.4, delay: 1.0, animations: { 
                self.thumbImageView.alpha = 0
            }, completion: nil)
            return image
        }
        
        // Here's the spot to prepare for hero animation if required
        if let startFrame = self.heroTransitionStartFrame {
            self.prepHeroTransition(from: startFrame)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if preparedForHeroTransition {
            self.startHeroTransition()
        }
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressAccept(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        
        if let image = self.image {
            self.acceptBlock?(image)
        } else {
            NSLog("Warning - pressed accept for nil image")
        }
    }
    
    
    // MARK:- Hero Transition
    
    
    /// The hero transition:
    /// 1. Start with the VC transparent on top, render the thumbnail perfectly on top of it's start frame so it should look like nothing has changed.
    /// 2. Animate the location and size of the image to it's final frame (imageView.frame as described in the storyboard.)
    /// 3. At the same time (maybe with slight delay?) fade in the dialog backgrounds - the dark translucency of the background view and the white dialog frame + buttons
    /// Meanwhile, we're showing a thumbnail - we can use this opportunity to pull the full size image and, once we have it, update the image with the higher resolution version (cross fading?) Note this step is taken care of by how we set up our imageView in our view controller lifecycle methods above
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
