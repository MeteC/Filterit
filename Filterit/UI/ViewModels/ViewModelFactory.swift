//
//  ViewModelFactory.swift
//  Filterit
//
//  Created by Mete Cakman on 17/08/21.
//  Copyright © 2021 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift

/// Factory class for instantiating concrete ViewModels for our app
struct ViewModelFactory {
    
    // MARK:- Construction Methods
    
    /// Provides the default implementation of LibraryViewModel, which uses our
    /// underlying Artwork model layer to generate its child view models.
    public static func createLibraryViewModel() -> LibraryViewModel {
        return LibraryViewModelImpl()
    }
    
    /// Provide the default implementation of LibraryThumbCellViewModel.
    public static func createLibraryThumbCellViewModel(artwork: ArtworkWrapper) -> LibraryThumbCellViewModel {
        return LibraryThumbCellViewModelImpl(artwork: artwork)
    }
    
    
    /// Create a concrete ShowArtworkViewModel based on a LibraryThumbCellViewModel
    /// ancestor and a defined starting image view.
    /// - Parameters:
    ///   - libraryThumbCellViewModel: Ancestor library thumb cell view model to construct from
    ///   - startingImageView: The starting image view used for accurate "hero" transition.
    public static func createShowArtworkViewModel(from libraryThumbCellViewModel: LibraryThumbCellViewModel, 
                                                  startingImageView: UIImageView) -> ShowArtworkViewModel {
        return ShowArtworkViewModelImpl(heroTransitionSourceImageView: startingImageView, 
                      image: libraryThumbCellViewModel.image, 
                      caption: libraryThumbCellViewModel.caption, 
                      rating: libraryThumbCellViewModel.rating)
    }
    
}


// MARK:- Concrete Implementations
extension ViewModelFactory {
    
    /// The simple default implementation of our LibraryViewModel.
    /// Accesses our ArtworkWrapper model layer and provides view models for all our
    /// thumbnail cells.
    private struct LibraryViewModelImpl: LibraryViewModel {
        func fetchCellModels() -> Single<[LibraryThumbCellViewModel]> {
            return ArtworkWrapper.fetchAllRx()
                .map { artworkList in
                    artworkList.map(LibraryThumbCellViewModelImpl.init(artwork:))
                }
        }
    }
    
    /// Our default LibrayThumbCell ViewModel is a very thin wrapper around our artwork.
    private struct LibraryThumbCellViewModelImpl: LibraryThumbCellViewModel {    
        private let artwork: ArtworkWrapper
        
        internal init(artwork: ArtworkWrapper) {
            self.artwork = artwork
        }
        
        public var image: UIImage? { artwork.image }
        public var rating: Int { Int(artwork.rating) }
        public var caption: String? { artwork.caption }
    }

    /// Our ShowArtworkViewModel implementation. Nothing tricky here.
    private struct ShowArtworkViewModelImpl: ShowArtworkViewModel {
        public let heroTransitionSourceImageView: UIImageView
        public let image: UIImage?
        public let caption: String?
        public let rating: Int
    }
}
