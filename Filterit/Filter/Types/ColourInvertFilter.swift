//
//  ColourInvertFilter.swift
//  Filterit
//
//  Created by Mete Cakman on 6/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit

/// Invert the colours
struct ColourInvertFilter: FilterType {
    
    var presentationTitle: String {
        NSLocalizedString("Invert Colours", comment: "")
    }
    
    func filter(forImageSize imageSize: CGSize) -> FilterGraph? {
        var graph: FilterGraph? = nil
        
        if let filter = CIFilter(name: "CIColorInvert") {
            graph = FilterGraph(inputFilter: filter)
        }
        
        return graph
    }
}
