//
//  ShowArtworkViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 24/08/2020.
//  Copyright © 2020 Mete Cakman. All rights reserved.
//

import UIKit
import SwifterSwift
import RxSwift
import RxCocoa
import FCAlertView


/// View Controller for showing our library artwork. 
/// Has a hero transition like in ImageApprovalViewController (albeit simpler).
class ShowArtworkViewController: UIViewController {

    /// To be set during segue, to show the correct artwork
    private var artwork: ArtworkWrapper?
    
    /// And we'll store a weak reference to the underlying image view from which we're transitioning
    private weak var underlyingImageView: UIImageView?

    // Rx Gear
    private let disposeBag = DisposeBag()
    
    /// Use constraints to transition our artwork image
    @IBOutlet weak var artworkImageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var artworkImageConstraintLeft: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundDarkenView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsCaptionLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    // TODO: Pull out rating stars from their various places, make a separate RatingsView to reuse.
    @IBOutlet weak var ratingStar1: UIImageView!
    @IBOutlet weak var ratingStar2: UIImageView!
    @IBOutlet weak var ratingStar3: UIImageView!
    @IBOutlet weak var ratingStar4: UIImageView!
    @IBOutlet weak var ratingStar5: UIImageView!
    
    
    /// Call this during segue to set artwork correctly and prepare our appearance transition
    /// - Parameters:
    ///   - artwork: The artwork to show
    ///   - underlyingImageView: The origin image view we'll use as the start point for
    ///   our hero transition animation
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
        
        setupActionsRx()
    }
    
    /// RxCocoa Binders are normally used to clearly demarcate assignation style
    /// subscriptions, but I find they can also be used to nicely separate the
    /// imperative requirements of action code from the declarative code setting up
    /// control elements' Rx subscriptions.
    ///
    /// This "action binder" performs our Share button functionality
    private var shareActionBinder: Binder<UIImage> {
        Binder(self) { (`self`, image) in
            // Show the standard iOS share view controller
            let shareVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            // We'll add a completion handler to deal with actions of interest - like
            // successfully saving to the photo roll
            shareVC.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
                if completed, let type = activityType {
                    if type == .saveToCameraRoll {
                        let alert = FCAlertView()
                        SaveDialog.applyTheme(to: alert)
                        alert.showAlert(withTitle: NSLocalizedString("Saved!", comment: ""), 
                                        withSubtitle: NSLocalizedString("Your artwork has been saved to your iOS Photos library", comment: ""), 
                                        withCustomImage: nil, 
                                        withDoneButtonTitle: NSLocalizedString("OK", comment: ""), 
                                        andButtons: [])
                    }
                }
            }
            self.present(shareVC, animated: true, completion: nil)
        }
    }
    
    /// We'll set up user interaction - tap to close, and share button, using Rx
    /// subscriptions.
    private func setupActionsRx() {
        
        // Add tap gesture to close, demonstrating use of Rx rather than the traditional
        // objc selector
        let tap = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tap)
        tap.rx.event
            .filter { $0.state == .ended }
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // Add share button action. We can ensure image is valid before binding our action
        if let image = self.artwork?.image {
            shareButton.rx.tap
                .map { image }
                .bind(to: shareActionBinder)
                .disposed(by: disposeBag)
        } else {
            NSLog("ERROR: artwork.image is not set correctly, share button disabled")
            shareButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.layoutForFrameSize(UIScreen.main.bounds.size)
        
        // prepare for animations present in viewDidAppear
        self.backgroundDarkenView.alpha = 0
        self.detailsView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animate in hero transition, and bring up details panel.
        // First hide the original artwork view while the hero transition is occurring, 
        // to prevent visibility of the backing layer.
        self.underlyingImageView?.isHidden = true
        
        // Fade background to dark, then animate our artwork into full frame.
        // We'll also fade the details view in
        let artworkInsetMargin: CGFloat = 0
        let artworkTopMargin: CGFloat = self.view.size.height * 0.1
        let artworkBottomMargin: CGFloat = self.view.size.height * 0.33
        
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
                self.artworkImageConstraintTop.constant = artworkTopMargin
                self.artworkImageConstraintLeft.constant = artworkInsetMargin
                self.artworkImageConstraintBottom.constant = artworkBottomMargin
                self.artworkImageConstraintRight.constant = artworkInsetMargin
                self.view.layoutIfNeeded()
            }
        } completion: { (finished) in
            // on finish undo change to underlying view layers
            self.underlyingImageView?.isHidden = false
        }
        
        UIView.animate(withDuration: heroTransitionDuration, delay: backgroundFadeDuration) { 
            self.detailsView.alpha = 1
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.layoutForFrameSize(size)
    }
    
    /// Landscape size screens will hide the caption, portrait will show if caption isn't empty
    private func layoutForFrameSize(_ size: CGSize) {
        let isPortrait = size.aspectRatio <= 1
        let caption = self.artwork?.caption ?? ""
        self.detailsView.isHidden = !isPortrait || caption.isEmpty
    }
}
