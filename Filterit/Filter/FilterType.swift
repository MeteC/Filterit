//
//  FilterType.swift
//  Filterit
//
//  Created by Mete Cakman on 10/10/2019.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit


protocol FilterType {
    
    /// Provide the actual CIFilter graph for this FilterType
    /// 
    /// - Parameter forImageSize: the input image size is necessary for certain filters (like cropping)
    /// - Returns: Optional filter graph, nil if filter creation failed
    func filter(forImageSize imageSize: CGSize) -> FilterGraph?
    
    /// Apply the given filter type to a UIImage input
    /// - Parameter image: the input image
    /// - Returns: Optional filtered image result, or nil if the filter failed
    func apply(to image: UIImage) -> UIImage?
    
    /// User interface title for humans to read
    var presentationTitle: String { get }
}

extension FilterType {
    
    /// Default apply (most filter types will just use their own FilterGraph)
    func apply(to image: UIImage) -> UIImage? {
        guard let filterGraph = self.filter(forImageSize: image.size) else {
            NSLog("FilterType \(self) - Filter setup failure - couldn't create filter graph")
            return nil
        }
        
        return filterGraph.apply(to: image)
    }
}


/// A pass-through filter
struct NoneFilter: FilterType {
    
    var presentationTitle: String {
        NSLocalizedString("No Filter", comment: "")
    }
    
    func filter(forImageSize imageSize: CGSize) -> FilterGraph? {
        return nil
    }
    
    func apply(to image: UIImage) -> UIImage? {
        return image
    }
}

/// A standard sepia filter
struct SepiaFilter: FilterType {
    
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

/// Apply a vignette (darkened image peripheries)
struct VignetteFilter: FilterType {
    
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

/// Simulates the effect of zooming the camera while capturing the image.
struct ZoomBlurFilter: FilterType {
    
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
