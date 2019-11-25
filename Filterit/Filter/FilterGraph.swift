//
//  FilterGraph.swift
//  Filterit
//
//  Created by Mete Cakman on 25/11/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit

/**
 Linear filter graph class just stores pointers to all its filters, with easy access to input and output filters.
 */
class FilterGraph {
    private var filters = [CIFilter]()
    
    /// Init forces at least one filter
    init(inputFilter: CIFilter) {
        filters.append(inputFilter)
    }
    
    /// Add the next filter to the graph chain. All filters will be applied
    /// in order of insertion in the graph.
    public func add(nextFilter filter: CIFilter) {
        filters.append(filter)
    }
    
    /// Retrieve the input filter stage
    var inputFilter: CIFilter {
        return filters.first!
    }
    
    /// Retrieve the output filter stage (may be equal to the input filter)
    public var outputFilter: CIFilter {
        return filters.last!
    }
    
    
    /// Apply the filter chain to an input image
    /// - Parameter image: input image
    /// - Returns: Optional filtered image result, or nil if the filter(s) failed 
    public func apply(to image: UIImage) -> UIImage? {
        
        guard let inputCgImage = image.cgImage else {
            NSLog("FilterGraph input failure - couldn't get CGImage of input image")
            return nil
        }
        
        // use reduce to chain the filters together
        let _ = self.filters.reduce(self.inputFilter) { (previousFilter, filter) -> CIFilter in
            if previousFilter == filter { // initial condition
                filter.setValue(CIImage(cgImage: inputCgImage), forKey: kCIInputImageKey)
            } else {
                filter.setValue(previousFilter.outputImage, forKey: kCIInputImageKey)
            }
            return filter
        }
        
        guard let outputCiImage = self.outputFilter.outputImage,
            let outputImage = CIContext().createCGImage(outputCiImage, from: outputCiImage.extent) else {
                NSLog("FilterGraph failure - Filter output failed and returned nil")
                return nil
        }
        
        
        return UIImage(cgImage: outputImage)
    }
}
