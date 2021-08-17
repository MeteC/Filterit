//
//  WelcomeViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 29/09/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift

/// The "landing page" welcomes users. They can switch tabs to show the library, or
/// start the artwork creation process.
class WelcomeViewController: UIViewController {
    
    // UI
    @IBOutlet weak var titleStackView: UIStackView!

    // Rx
    let disposeBag = DisposeBag()
    
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let isLandscapeAspect = view.size.width > view.size.height
        configureUi(landscape: isLandscapeAspect, animate: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let isLandscapeAspect = size.aspectRatio > 1
        configureUi(landscape: isLandscapeAspect, animate: true)
    }
    
    /// Some differences between landscape and portrait mode need to be done
    /// programmatically, rather than using Interface Builder settings.
    /// - Parameters:
    ///   - landscape: true for landscape mode, else portrait
    ///   - animate: whether to animate changes or not. Currently unused but left in place while developing for ease!
    private func configureUi(landscape: Bool, animate: Bool) {
        // When switching to landscape, let's swivel our title stack to horizontal layout
        self.titleStackView.axis = landscape ? .horizontal : .vertical
        self.titleStackView.alignment = landscape ? .firstBaseline : .center
    }
}
