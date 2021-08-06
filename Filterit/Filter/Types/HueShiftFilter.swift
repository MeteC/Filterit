//
//  HueShiftFilter.swift
//  Filterit
//
//  Created by Mete Cakman on 6/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit

public struct HueShiftFilter: FilterType {
    
    public let angle: Int
    
    func filter(forImageSize imageSize: CGSize) -> FilterGraph? {
        var graph: FilterGraph? = nil
        
        if let filter = CIFilter(name: "CIHueAdjust") {
            filter.setValue(NSNumber(floatLiteral: Double(angle)), forKey: kCIInputAngleKey)
            graph = FilterGraph(inputFilter: filter)
        }
        
        return graph
    }
    
    var presentationTitle: String { 
        NSLocalizedString("\(angle)º Hue Shift", comment: "") 
    }
}
