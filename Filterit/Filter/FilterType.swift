//
//  FilterType.swift
//  Filterit
//
//  Created by Mete Cakman on 10/10/2019.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit

/// Filter logic - allow for filtering of input images using basic enumerated hard-coded CIFilters
enum FilterType: CaseIterable {
    
    case none                   // A pass-through filter
    case sepia                  // A standard sepia filter
    case colourInvert           // Invert the colours
    case vignette               // Apply a vignette (darkened image peripheries)
    case zoomBlur               // Simulates the effect of zooming the camera while capturing the image.
    
    
    /// Apply the given filter type to a UIImage input
    /// - Parameter image: the input image
    /// - Returns: Optional filtered image result, or nil if the filter failed
    public func apply(to image: UIImage) -> UIImage? {
        
        // Quick check for `none` condition - just pass through here
        if self == .none {
            return image
        }
        
        guard let filterGraph = self.filter(forImageSize: image.size) else {
            NSLog("FilterType \(self) - Filter setup failure - couldn't create filter graph")
            return nil
        }
        
        return filterGraph.apply(to: image)
    }
    
    
    /// Provide the actual CIFilter graph for this FilterType
    /// 
    /// - Parameter forImageSize: the input image size is necessary for certain filters (like cropping)
    /// - Returns: Optional filter graph, nil if filter creation failed
    private func filter(forImageSize imageSize: CGSize) -> FilterGraph? {
        
        var graph: FilterGraph? = nil
        
        switch self {
            
        case .none:
            break
            
        case .sepia:
            if let filter = CIFilter(name: "CISepiaTone") {
                filter.setValue(0.5, forKey: kCIInputIntensityKey)
                graph = FilterGraph(inputFilter: filter)
            }
            
        case .colourInvert:
            if let filter = CIFilter(name: "CIColorInvert") {
                graph = FilterGraph(inputFilter: filter)
            }
            
        case .vignette:
            if let filter = CIFilter(name: "CIVignette") {
                filter.setValue(0.9, forKey: kCIInputIntensityKey)
                graph = FilterGraph(inputFilter: filter)
            }
            
        case .zoomBlur:
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
                NSLog("d: \(cropVector)")
                
                filter.setValue(blurValue, forKey: kCIInputAmountKey)
                
                cropFilter.setValue(cropVector, forKey: "inputRectangle")
                
                graph = FilterGraph(inputFilter: filter)
                graph?.add(nextFilter: cropFilter)
            }
        }
        
        if graph == nil {
            NSLog("WARNING: filter type \(self) returned nil filter")
        }
        return graph
    }
}
