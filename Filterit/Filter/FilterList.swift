//
//  FilterList.swift
//  Filterit
//
//  Created by Mete Cakman on 7/2/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import Foundation


/// System-wide list of instantiated filters for convenience.
/// Since we always use all filters, we can use a statically compiled list of them.
/// Similar to how you might use Swift CaseIterable enum (calling `.allCases`).
class FilterList {
    public static let values: [FilterType] = 
        [
            NoneFilter(),
            SepiaFilter(),
            ColourInvertFilter(),
            VignetteFilter(),
            ZoomBlurFilter()
        ]
}
