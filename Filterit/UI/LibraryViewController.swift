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
            
            cell.imageView.image = element.image
        }
        .disposed(by: disposeBag)
    }

}

// MARK: - LibraryThumbCell
class LibraryThumbCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
}
