//
//  ApplyFilterViewController.swift
//  StockFilter
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    // MARK: - Development Rig
    
    private var filterTestingCounter = 0
    @IBAction func pressTestsButton(_ sender: Any) {
        
        // each time you press Test, cycle through the filters available in FilterType
        filterTestingCounter += 1
        
        let allFilters = FilterType.allCases 
        let filterType = allFilters[ filterTestingCounter % allFilters.count ]

        NSLog("Testing - applying filter \(filterType) to inputImage")
        resultImageView.image = filterType.apply(to: inputImage!)
    }
}
