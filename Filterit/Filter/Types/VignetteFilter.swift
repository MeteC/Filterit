//
//  VignetteFilter.swift
//  Filterit
//
//  Created by Mete Cakman on 6/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit


/// Apply a vignette (darkened image peripheries)
public struct VignetteFilter: FilterType {
    
    var presentationTitle: String {
        NSLocalizedString("Vignette", comment: "")
    }
    
    func filter(forImageSize imageSize: CGSize) -> FilterGraph? {
        var graph: FilterGraph? = nil
        
        if let filter = CIFilter(name: "CIVignette") {
            filter.setValue(0.9, forKey: kCIInputIntensityKey)
            graph = FilterGraph(inputFilter: filter)
        }
        
        return graph
    }
}
