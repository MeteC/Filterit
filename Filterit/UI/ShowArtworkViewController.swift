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
    
    @IBOutlet weak var backgroundDarkenView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    /// Call this during segue to set artwork correctly and prepare our appearance transition
    /// - Parameters:
    ///   - artwork: The artwork to show
    ///   - startFrame: The starting frame to transition in our image from. 
    ///   (Will be the window frame of the same artwork view presented in the library.)
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
        self.artworkImageView.frame = startFrame
        
        self.view.sendSubviewToBack(self.backgroundDarkenView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fade background to dark while animating our artwork into frame
        self.backgroundDarkenView.alpha = 0
        
        UIView.animate(withDuration: 0.5) { 
            self.backgroundDarkenView.alpha = 1
            self.artworkImageView.frame = self.view.frame.insetBy(dx: 16, dy: 16)
        }
    }
}
