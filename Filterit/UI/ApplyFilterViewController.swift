//
//  ApplyFilterViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 30/09/2019.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift

/// View controller for applying filters to an input image, and then passing the result on
class ApplyFilterViewController: UIViewController {

    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var resultImageView: UIImageView!
    
    /// Set this before launching the VC, holds the input photo / image
    private var inputImage: UIImage? = nil
    
    let disposeBag = DisposeBag()
    
    
    /// Set the input image before launching the VC, or you'll be told..
    public func setInputImage(_ image: UIImage) {
        self.inputImage = image
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Did you remember to set the input image?
        assert(self.inputImage != nil, "Input image not set for ApplyFilterVC - be sure to set it before displaying ApplyFilterViewController!")
        
        // Apply the image to our view.. the user can now change this using filter controls
        resultImageView.image = inputImage
        
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    /// Set up all Rx bindings for this controller
    private func setupRx() {
        
        // We can create our filter collection data source from our FilterType enumerator, since it's case iterable
        Observable
            .of(FilterType.allCases)
            .bind(to: filterCollectionView.rx.items(cellIdentifier: "FilterCell", cellType: FilterCell.self)) 
        { (row, filter, cell) in
            
            let viewModel = FilterTypeViewModel(filter: filter)
            
            cell.filterTitle.text = viewModel.presentationTitle()
            cell.sampleImageView.image = viewModel.presentationImage()
            
            // add a border to the image
            cell.sampleImageView.layer.borderColor = UIColor.black.cgColor
            cell.sampleImageView.layer.borderWidth = 1.0
        }
        .disposed(by: disposeBag)
        
        
        // tap handling - apply the filter, let's also indicate which filter is currently applied
        filterCollectionView.rx.modelSelected(FilterType.self)
            .subscribe(onNext: { filterType in
                self.resultImageView.image = filterType.apply(to: self.inputImage!)
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK: - ImageThumbCell
class FilterCell: UICollectionViewCell {
    @IBOutlet weak var filterTitle: UILabel!
    @IBOutlet weak var sampleImageView: UIImageView!
    
    // Custom effect for selected cell
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = (UIColor(named: "Accent") ?? UIColor.systemYellow).cgColor
            self.layer.borderWidth = self.isSelected ? 1.0 : 0.0
        }
    }
}

// MARK: - FilterType ViewModel

/// View-model layer, provides UI content for our FilterCells for all FilterType filters
struct FilterTypeViewModel {
    
    let filter: FilterType
    
    /// Presentation title for our filter
    func presentationTitle() -> String {
        switch filter {
        
        case .none:
            return NSLocalizedString("No Filter", comment: "")
        case .sepia:
            return NSLocalizedString("Sepia", comment: "")
        case .colourInvert:
            return NSLocalizedString("Invert Colours", comment: "")
        case .vignette:
            return NSLocalizedString("Vignette", comment: "")
        
        }
    }
    
    /// Presentation sample image for our filter
    func presentationImage() -> UIImage? {
        if let sample = UIImage(named: "SamplePupIcon") {
            return filter.apply(to: sample)
        }
        return nil
    }
}
