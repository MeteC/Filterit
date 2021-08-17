//
//  LibraryViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 14/01/2020.
//  Copyright © 2020 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift


/// Our library collection view. Displays our current library of images; enables
/// user to tap to view artwork.
class LibraryViewController: UIViewController {

    // (Segue name as in IB)
    private static let segueNameShowArtwork = "showArtwork"
    
    // UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// ViewModel dependency (injectable). Defaults to our "core" implementation.
    public var viewModel: LibraryViewModel = ViewModelFactory.createLibraryViewModel()
    
    // Rx
    private let disposeBag = DisposeBag()
    
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        setupRx()
    }
    
    /// Set up all Rx bindings for this controller
    private func setupRx() {
        
        let onAppear = self.rx
            .methodInvoked(#selector(viewWillAppear(_:)))
        
        // On view appearance, pull all artwork and bind them to our collection view
        onAppear
            .flatMapLatest { _ in self.viewModel.fetchCellModels() }
            .bind(to: collectionView.rx.items(cellIdentifier: "LibraryCell", cellType: LibraryThumbCell.self)) {
            (row, element, cell) in
                cell.apply(viewModel: element)
        }
        .disposed(by: disposeBag)
        
        
        // On selection we need to pull the starting frame of the image (for transition effect), as well
        // as the artwork in question. Using a zip to combine model and item selected sequences.
        Observable.zip(collectionView.rx.itemSelected, 
                       collectionView.rx.modelSelected(LibraryThumbCellViewModel.self))
            .subscribe(onNext: { (indexPath, cellViewModel) in
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? LibraryThumbCell else {
                    assert(false, "itemSelected failed to provide cell/layout")
                    return
                }
                
                // Pass tuple of required info as sender data
                self.performSegue(withIdentifier: LibraryViewController.segueNameShowArtwork, 
                                  sender: (cellViewModel, cell.imageView))
            })
            .disposed(by: disposeBag)
    }

    /// Deal with screen and orientation changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // on screen transitions, reload collection view to resize cells
        if let cv = self.collectionView {
            // Note with library in a tab, it's possible that iOS calls this method before collectionView is set up from IB!
            cv.reloadData()
        }
    }
    
    /// Currently just segueing to "Show Artwork" view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowArtworkViewController {
            // sender == (LibraryThumbCellViewModel, UIImageView) tuple
            guard let (cellViewModel, imageView) = sender as? (LibraryThumbCellViewModel, UIImageView) else {
                NSLog("Error - must pass (LibraryThumbCellViewModel, UIImageView) tuple as sender here")
                return
            }
            
//            destination.prepare(with: cellViewModel.artwork, 
//                                underlyingImageView: imageView)
            destination.prepare(viewModel: ViewModelFactory.createShowArtworkViewModel(from: cellViewModel, startingImageView: imageView))
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
    // Using FlowLayout delegation to achieve the desired collection view layout:
    // I want an exact fit for the cells horizontally such that they're no bigger than
    // 200 px across, so I'll be dividing the screen width by the smallest integer N
    // such that width W < 200, where N corresponds to column count.
    
    /// Customise the cell size based on screen dimensions
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = self.view.bounds.size.width
        
        // a default margin (8 per side) - but let's actually access the margins we've attributed in IB..
        var perCellMargin: CGFloat = 16.0 
        if let insets = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset {
            perCellMargin = insets.left + insets.right
        }
        let kMaxSideLength: CGFloat = 200
        
        var columnCount = 1
        var sideLength: CGFloat = 0
        
        repeat {
            columnCount += 1
            sideLength = (screenWidth / CGFloat(columnCount)) - perCellMargin
        }
        while sideLength > kMaxSideLength 
        
        return CGSize(width: sideLength, height: sideLength)
    }
}


// MARK: - LibraryThumbCell
class LibraryThumbCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingView: RatingView!
    
    /// A very simple example of using a ViewModel, and perhaps not required for such a
    /// small project, but this demonstrates the concept at least!
    fileprivate func apply(viewModel: LibraryThumbCellViewModel) {
        imageView.image = viewModel.image
        ratingView.rating = viewModel.rating
    }
}
