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
