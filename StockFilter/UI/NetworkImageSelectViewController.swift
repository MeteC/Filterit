//
//  NetworkImageSelectViewController.swift
//  StockFilter
//
//  Created by Mete Cakman on 24/09/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import moa


/// View controller for pulling image data from our online API, presenting image options for selection,
/// and later segueing off to e.g. apply filters
class NetworkImageSelectViewController: UIViewController {

    /// Will animate cells based on touch input
    private static let kCellAnimationDuration = 0.15
    
    // Interface Bindings
    
    @IBOutlet weak var thumbCollectionView: UICollectionView!
    @IBOutlet weak var refreshButtonItem: UIBarButtonItem!
    
    /// An overhead progress display used while pulling data from the API
    private var hudSpinner: MBProgressHUD?
    
    // Rx Gear
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle & Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hiding back button here establishes this view controller as the base in the navigation stack. So you don't go all the way back to the welcome screen once you start.
        self.navigationItem.hidesBackButton = true
        setupRx()
    }
    
    /// Setup all Rx bindings for this controller
    private func setupRx() {
        
        // on appear, we want to pull API data. However this would create an observable of Observable<[Photo]>, so then we flatMapLatest it.
        let onAppear = self.rx
            .methodInvoked(#selector(viewDidAppear(_:)))
            .take(1) // "do once"
            .flatMapLatest { _ in self.pullAPIData() }
        
        // on tap, we map out our API data observable
        let onTap = refreshButtonItem.rx.tap.flatMapLatest { self.pullAPIData() }
        
        // We merge both of the above event sequences into one, so our dataSource is driven by viewDidAppear AND refresh button tap.
        let dataSource = Observable.merge([onAppear, onTap]) // note you merge two sequences of the same type
        
        dataSource.bind(to: thumbCollectionView.rx.items(cellIdentifier: "ImageThumbCell", cellType: ImageThumbCell.self)) 
        { (row, element, cell) in
            
            cell.imageView.moa.url = element.thumbUrl
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1.0
        }
        .disposed(by: disposeBag)

        // highlighting the cell gives a little growth animation
        thumbCollectionView.rx
            .itemHighlighted
            .compactMap { self.thumbCollectionView.cellForItem(at: $0) }
            .subscribe(onNext: { (cell) in
                UIView.animate(withDuration: NetworkImageSelectViewController.kCellAnimationDuration, 
                               delay: 0.0, 
                               options: .curveEaseOut, 
                               animations: 
                    { 
                        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
            })
            .disposed(by: disposeBag)
        
        
        // Using a zip to combine model and item selected sequences
        Observable.zip(thumbCollectionView.rx.itemSelected, thumbCollectionView.rx.modelSelected(Image.self))
            .subscribe(onNext: { (index, image) in
                guard let cell = self.thumbCollectionView.cellForItem(at: index) as? ImageThumbCell,
                    let layout = self.thumbCollectionView.layoutAttributesForItem(at: index) else {
                        assert(false, "itemSelected failed to provide cell/layout")
                        return
                }
                
                // Now got model, cell, and layout (without needing any static data sources)
//                cell.layer.borderColor = UIColor.red.cgColor
                print("Cell tapped at \(layout.frame)")
                print("Tapped photo \(image.title ?? "Untitled")")
                
                // We can make the "hero" transition to our dialog using the cell layout frame info,
                // plus knowledge of which image we're using
                if let vc = self.storyboard?.instantiateViewController(identifier: "ImageApprovalViewController") as? ImageApprovalViewController {
                    
                    vc.image = image
                    vc.imageThumb = cell.imageView.image 
                    vc.heroTransitionStartFrame = self.thumbCollectionView.convert(layout.frame, to: self.thumbCollectionView.superview)
                    vc.acceptButtonTitle = "Apply Filter"
                    self.present(vc, animated: false, completion: nil)
                } else {
                    print("Error instantiating ImageApprovalViewController from storyboard!")
                }
            })
            .disposed(by: disposeBag)
        
        // revert highlight changes
        thumbCollectionView.rx
            .itemUnhighlighted
            .compactMap { self.thumbCollectionView.cellForItem(at: $0) }
            .subscribe(onNext: { (cell) in
                UIView.animate(withDuration: NetworkImageSelectViewController.kCellAnimationDuration) { 
                    cell.transform = .identity
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    private func setHudVisible(_ visible: Bool) {
        if visible {
            hudSpinner = MBProgressHUD.showAdded(to: self.view, animated: true)
            hudSpinner!.label.text = "Checking Server"
            hudSpinner!.backgroundColor = UIColor(white: 0, alpha: 0.5) // dark
        } else {
            hudSpinner?.hide(animated: true)
            hudSpinner = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // not checking segue identifier, as our destination VC type is more interesting in this case 
        if let vc = segue.destination as? ApplyFilterViewController {
            vc.setInputImage(UIImage(named: "SamplePup")!) // experimental (`!` not good for production code). TODO: pass in the actual selection
        }
    }
    
    // MARK: - API Calls
    
    /// Call our APIManager to get the latest observable list of images.
    /// Ensure progress UI is displayed/hidden appropriately
    private func pullAPIData() -> Observable<[Image]> {
        
        // this API request can be super quick - so quick that the HUD UI popping up looks almost like a glitch. I'll put in a minimum display time of 0.5 secs to avoid that 
        let startTime = Date()
        
        // Use driver trait to ensure main thread + no errors, use side-effects for HUD display
        return APIManager().listImages()
            .asDriver(onErrorJustReturn: [])
            .do(afterCompleted: { 
                let deadline = DispatchTime.now() + max(0.5, Date().timeIntervalSince(startTime))
                DispatchQueue.main.asyncAfter(deadline: deadline) { 
                    self.setHudVisible(false)
                }
            }, onSubscribed: { 
                self.setHudVisible(true)
            })
            .asObservable()
    }
}

// MARK: - ImageThumbCell
class ImageThumbCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
}
