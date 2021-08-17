//
//  ApplyFilterViewModel.swift
//  Filterit
//
//  Created by Mete Cakman on 17/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit

/// The ViewModel for our "Apply Filter" stage.
/// Output: the input image for applying filters.
/// Input: functionality to save to database.
protocol ApplyFilterViewModel {
    
    /// The input image for filtering
    var inputImage: UIImage { get }
    
    /// Save result data to a database. Throws on failure.
    func save(result: UIImage, caption: String, date: Date, rating: Int) throws
}
