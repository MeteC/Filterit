//
//  NoneFilter.swift
//  Filterit
//
//  Created by Mete Cakman on 6/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit

/// A pass-through filter
public struct NoneFilter: FilterType {
    
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
