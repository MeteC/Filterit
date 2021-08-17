//
//  LibraryViewModel.swift
//  Filterit
//
//  Created by Mete Cakman on 17/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import Foundation
import RxSwift


/// LibraryViewModel just provides a list of library thumbnail cell view models,
/// used to set up collection view cells in turn.
protocol LibraryViewModel {
    
    /// Fetches the current list of library thumb cell view models to apply to our
    /// collection.
    func fetchCellModels() -> Single<[LibraryThumbCellViewModel]>
}


/// LibraryThumbCellViewModel used to set up library thumbnail cells.
/// It's just an ArtworkViewModel.
protocol LibraryThumbCellViewModel: ArtworkViewModel {}
