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
    var presentationTitle: String {
        filter.presentationTitle
    }
    
    /// Presentation sample image for our filter
    func presentationImage() -> UIImage? {
        if let sample = UIImage(named: "SamplePupIcon") {
            return filter.apply(to: sample)
        }
        return nil
    }
}

