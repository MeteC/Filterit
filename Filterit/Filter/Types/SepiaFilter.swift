//
//  SepiaFilter.swift
//  Filterit
//
//  Created by Mete Cakman on 6/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit


/// A standard sepia filter
public struct SepiaFilter: FilterType {
    
    var presentationTitle: String {
        NSLocalizedString("Sepia", comment: "")
    }
    
    func filter(forImageSize imageSize: CGSize) -> FilterGraph? {
        var graph: FilterGraph? = nil
        
        if let filter = CIFilter(name: "CISepiaTone") {
            filter.setValue(0.5, forKey: kCIInputIntensityKey)
            graph = FilterGraph(inputFilter: filter)
        }
        
        return graph
    }
}
