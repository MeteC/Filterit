//
//  ArtworkViewModel.swift
//  Filterit
//
//  Created by Mete Cakman on 17/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit

/// Basic Artwork ViewModel requirements are shared amongst different protocols in
/// Filterit, and we can use the very cool Swift feature of protocol inheritance
/// here.
protocol ArtworkViewModel {
    
    /// Artwork image
    var image: UIImage? { get }
    
    /// Artwork caption
    var caption: String? { get }
    
    /// Artwork rating
    var rating: Int { get }
}
