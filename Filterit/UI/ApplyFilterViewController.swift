//
//  ApplyFilterViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 30/09/2019.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift
import FCAlertView

/// View controller for applying filters to an input image, and then passing the result on
class ApplyFilterViewController: UIViewController {

    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    /// Set this before launching the VC via prepare
    private var viewModel: ApplyFilterViewModel?
    
    private let saveDialog = SaveDialog()
    private let disposeBag = DisposeBag()
    
    
    /// Be sure to set the view model before launching the VC, thus:
    public func prepare(viewModel: ApplyFilterViewModel) {
        self.viewModel = viewModel
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Select Filter", comment: "")

        // Did you remember to set the input image?
        guard let viewModel = self.viewModel else {
            NSLog("Error - must call prepare(with...) before loading view!")
            return
        }
        
        // Apply the image to our view.. the user can now change this using filter controls
        resultImageView.image = viewModel.inputImage
        
        setupRx(viewModel: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    /// Set up all Rx bindings for this controller
    private func setupRx(viewModel: ApplyFilterViewModel) {
        
        // We can create our filter collection data source from our FilterType enumerator, since it's case iterable
        Observable
            .of(FilterList.values)
            .bind(to: filterCollectionView.rx.items(cellIdentifier: "FilterCell", cellType: FilterCell.self)) 
        { (row, filter, cell) in
            
            let viewModel = FilterTypeViewModel(filter: filter)
            
            cell.filterTitle.text = viewModel.presentationTitle
            cell.sampleImageView.image = viewModel.presentationImage()
            
            // add a border to the image
            cell.sampleImageView.layer.borderColor = UIColor.black.cgColor
            cell.sampleImageView.layer.borderWidth = 1.0
        }
        .disposed(by: disposeBag)
        
        
        // tap handling - apply the filter, let's also indicate which filter is currently applied
        filterCollectionView.rx.modelSelected(FilterType.self)
            .subscribe(onNext: { filterType in
                let img = filterType.apply(to: viewModel.inputImage)
                self.resultImageView.image = img
            })
            .disposed(by: disposeBag)
        
        // Since SaveDialog is reactive, why not set up our "Save" button fully reactively here
        self.saveButton.rx.tap
            .flatMap { 
                self.saveDialog.showAlert(title: NSLocalizedString("Save Image", comment: ""), subtitle: nil) 
            }
            .asDriver(onErrorJustReturn: .cancel)
            .drive(onNext: { (result) in
                switch result {
                case .cancel:
                    NSLog("Cancelled save.")
                    
                case .save(let captionText, let rating):
                    guard let finalImage = self.resultImageView.image else {
                        NSLog("ERROR: Tried to save but couldn't access image - found nil on resultImageView!")
                        self.showAlertMessage(NSLocalizedString("Failed to save image!", comment: ""), asError: true)
                        break
                    }
                    
                    NSLog("Saving image with caption \(captionText) and rating \(rating)")
                    
                    do {
                        try viewModel.save(result: finalImage, caption: captionText, date: Date(), rating: rating)
                        self.showAlertMessage(NSLocalizedString("Successfully saved image!", comment: ""), asError: false)
                        
                    } catch {
                        NSLog("Failed to save artwork: \(error)")
                        self.showAlertMessage(NSLocalizedString("Failed to save image!", comment: ""), asError: true)
                    }
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    /// Present a message to the user, as either an error or a success type alert
    /// - Parameters:
    ///   - message: The message to present
    ///   - asError: Set true for error alert layouts, or false for success type
    private func showAlertMessage(_ message: String, asError: Bool) {
        let alert = FCAlertView()
        alert.darkTheme = (UIScreen.main.traitCollection.userInterfaceStyle == .dark)
        
        if asError { 
            alert.makeAlertTypeWarning()
        } else {
            alert.makeAlertTypeSuccess()
            alert.colorScheme = UIColor.init(named: "Accent")
        }
        
        let title = asError ? NSLocalizedString("Error", comment: "") : NSLocalizedString("Success", comment: "")
        alert.showAlert(withTitle: title, withSubtitle: message, withCustomImage: nil, withDoneButtonTitle: NSLocalizedString("OK", comment: ""), andButtons: [])
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
