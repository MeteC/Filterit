//
//  FilterType.swift
//  StockFilter
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

    
        /// Apply the given filter type to a UIImage input
        /// - Parameter image: the input image
        /// - Returns: Optional filtered image result, or nil if the filter failed
        public func apply(to image: UIImage) -> UIImage? {

            // Quick check for `none` condition - just pass through here
            if self == .none {
                return image
            }
            
            guard let inputCgImage = image.cgImage else {
                NSLog("FilterType \(self) - Filter input failure - couldn't get CGImage of input image")
                return nil
            }
            
            guard let filter = self.filter else {
                NSLog("FilterType \(self) - Filter setup failure - couldn't create CIFilter")
                return nil
            }
            
            
            filter.setValue(CIImage(cgImage: inputCgImage), forKey: kCIInputImageKey)
            
            guard let outputCiImage = filter.outputImage else {
                NSLog("FilterType \(self) - Filter output failed and returned nil")
                return nil
            }
            
            return UIImage(ciImage: outputCiImage)
        }
        
        
        /// Provide the actual CIFilter for this FilterType
        /// - Parameter input: the input image
        /// - Returns: Optional filter, nil if filter creation failed
        public var filter: CIFilter? {

            var returnFilter: CIFilter? = nil
            
            switch self {
                
            case .none:
                break
                
            case .sepia:
                if let filter = CIFilter(name: "CISepiaTone") {
                    filter.setValue(0.5, forKey: kCIInputIntensityKey)
                    returnFilter = filter
                }
                
            case .colourInvert:
                if let filter = CIFilter(name: "CIColorInvert") {
                    returnFilter = filter
                }
                
            case .vignette:
                if let filter = CIFilter(name: "CIVignette") {
                    filter.setValue(0.9, forKey: kCIInputIntensityKey)
                    returnFilter = filter
                }
            }
            
            return returnFilter
        }
    }

