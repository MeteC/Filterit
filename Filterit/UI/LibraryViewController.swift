//
//  LibraryViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 14/01/2020.
//  Copyright © 2020 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift

/// Our library collection view. Displays our current library of images and permits interaction
class LibraryViewController: UIViewController {

    // UI Gear
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Rx Gear
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        setupRx()
    }
    
    /// Set up all Rx bindings for this controller
    private func setupRx() {
        
        // on appear, we want to fetch all our library entries
        let onAppear = self.rx
            .methodInvoked(#selector(viewWillAppear(_:)))
            .flatMapLatest { _ in ArtworkWrapper.fetchAllRx() }
        
        // and bind them to our collection view
        onAppear.bind(to: collectionView.rx.items(cellIdentifier: "LibraryCell", cellType: LibraryThumbCell.self)) {
            (row, element, cell) in
            
            // Apply our look using a view model
            LibraryThumbCellViewModel(artwork: element, cell: cell).apply()
        }
        .disposed(by: disposeBag)
        
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // on screen transitions, reload collection view to resize cells
        self.collectionView.reloadData()
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
    
    @IBOutlet weak var ratingStar1: UIImageView!
    @IBOutlet weak var ratingStar2: UIImageView!
    @IBOutlet weak var ratingStar3: UIImageView!
    @IBOutlet weak var ratingStar4: UIImageView!
    @IBOutlet weak var ratingStar5: UIImageView!
    
}

// MARK: - LibraryThumbCellViewModel
/// A simple view-model that configures our library thumb cells nicely
struct LibraryThumbCellViewModel {
    
    let artwork: ArtworkWrapper
    let cell: LibraryThumbCell
    
    private static let filledStar = UIImage(systemName: "star.fill")
    private static let emptyStar = UIImage(systemName: "star")
    
    /// Take artwork, apply appropriate look to the supplied cell
    fileprivate func apply() {
        cell.imageView.image = artwork.image
        
        // just decluttering the next 5 lines a bit with shorthand
        let f = LibraryThumbCellViewModel.filledStar
        let e = LibraryThumbCellViewModel.emptyStar
        
        cell.ratingStar1.image = artwork.rating > 0 ? f:e
        cell.ratingStar2.image = artwork.rating > 1 ? f:e
        cell.ratingStar3.image = artwork.rating > 2 ? f:e
        cell.ratingStar4.image = artwork.rating > 3 ? f:e
        cell.ratingStar5.image = artwork.rating > 4 ? f:e
    }
}
