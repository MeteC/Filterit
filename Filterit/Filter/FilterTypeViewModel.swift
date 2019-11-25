//
//  FilterTypeViewModel.swift
//  Filterit
//
//  Created by Mete Cakman on 25/11/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit


// MARK: - FilterType ViewModel

/// View-model layer, provides UI content for our FilterCells for all FilterType filters
struct FilterTypeViewModel {
    
    let filter: FilterType
    
    /// Presentation title for our filter
    func presentationTitle() -> String {
        switch filter {
            
        case .none:
            return NSLocalizedString("No Filter", comment: "")
        case .sepia:
            return NSLocalizedString("Sepia", comment: "")
        case .colourInvert:
            return NSLocalizedString("Invert Colours", comment: "")
        case .vignette:
            return NSLocalizedString("Vignette", comment: "")
        case .zoomBlur:
            return NSLocalizedString("Zoom Blur", comment: "")
            
        }
    }
    
    /// Presentation sample image for our filter
    func presentationImage() -> UIImage? {
        if let sample = UIImage(named: "SamplePupIcon") {
            return filter.apply(to: sample)
        }
        return nil
    }
}

