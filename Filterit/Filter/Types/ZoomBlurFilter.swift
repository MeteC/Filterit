//
//  ZoomBlurFilter.swift
//  Filterit
//
//  Created by Mete Cakman on 6/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit


/// Simulates the effect of zooming the camera while capturing the image.
public struct ZoomBlurFilter: FilterType {
    
    var presentationTitle: String {
        NSLocalizedString("Zoom Blur", comment: "")
    }
    
    func filter(forImageSize imageSize: CGSize) -> FilterGraph? {
        var graph: FilterGraph? = nil
        
        // note - zoom blur also shifts the image up and right, so we'll correct for that here
        if let filter = CIFilter(name: "CIZoomBlur"), 
           let cropFilter = CIFilter(name: "CICrop") {
            
            // I've chosen a heavy zoom blur value, and played with numbers on the cropping filter to nicely cut out the whiteness added by the zoom blur filter
            let blurValue = 20
            let sideCropPercent: CGFloat = 0.1
            let cropVector = 
                CIVector(x: sideCropPercent * imageSize.width, 
                         y: sideCropPercent * imageSize.height, 
                         z: imageSize.width - 2 * (sideCropPercent * imageSize.width), 
                         w: imageSize.height - 2 * (sideCropPercent * imageSize.height))
            
            filter.setValue(blurValue, forKey: kCIInputAmountKey)
            
            cropFilter.setValue(cropVector, forKey: "inputRectangle")
            
            graph = FilterGraph(inputFilter: filter)
            graph?.add(nextFilter: cropFilter)
        }
        
        return graph
    }
}
