//
//  NoirFilter.swift
//  Filterit
//
//  Created by Mete Cakman on 6/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit

public struct NoirFilter: FilterType {
    
    func filter(forImageSize imageSize: CGSize) -> FilterGraph? {
        var graph: FilterGraph? = nil
        
        if let filter = CIFilter(name: "CIPhotoEffectNoir") {
            graph = FilterGraph(inputFilter: filter)
        }
        
        return graph
    }
    
    var presentationTitle: String { 
        NSLocalizedString("Film Noir", comment: "") 
    }
}
