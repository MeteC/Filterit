//
//  ShowArtworkViewModel.swift
//  Filterit
//
//  Created by Mete Cakman on 17/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit

/// ViewModel suitable for our ShowArtworkViewController (just for example ;-))
/// 
/// Presents the basic artwork requirements of image, caption, and rating, as well
/// as the source image view from which to start our hero transition, if the
/// implicated view controller were to want to do such a thing.
protocol ShowArtworkViewModel: ArtworkViewModel {
    
    /// The source image view from which to start our hero transition
    var heroTransitionSourceImageView: UIImageView { get }
}
