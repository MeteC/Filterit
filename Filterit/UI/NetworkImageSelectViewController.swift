//
//  NetworkImageSelectViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 24/09/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import moa
import SwifterSwift

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
    
    /// A strong reference to our image caching tools
    private let moa = Moa()
    
    // Rx Gear
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle & Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hiding back button here establishes this view controller as the base in the navigation stack. So you don't go all the way back to the welcome screen once you start.
        self.navigationItem.hidesBackButton = true
        setupRx()
    }
    
    /// Set up all Rx bindings for this controller
    private func setupRx() {
        
        // on appear, we want to pull API data. However this would create an observable of Observable<[Photo]>, so then we flatMapLatest it.
        let onAppear = self.rx
            .methodInvoked(#selector(viewDidAppear(_:)))
            .take(1) // "do once"
            .flatMapLatest { _ in self.pullAPIData() }
        
        // on tap, we map out our API data observable
        let onTap = refreshButtonItem.rx.tap.flatMapLatest { 
            self.pullAPIData() 
        }
        
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
                
                // Now we got model, cell, and layout (without needing any static data sources)
                NSLog("Tapped photo \(image.title ?? "Untitled")")
                
                // Pass in all required data for our ImageApprovalViewController to use its "hero" transition effect
                if let vc = self.storyboard?.instantiateViewController(identifier: "ImageApprovalViewController") as? ImageApprovalViewController {
                    
                    // dialog setup
                    vc.preConfigureForHeroTransition(with: image, 
                                                     thumbnail: cell.imageView.image, 
                                                     startFrame: self.thumbCollectionView.convert(layout.frame, to: self.thumbCollectionView.superview), 
                                                     acceptButtonTitle: NSLocalizedString("Select Filter", comment: "")) 
                    
                    vc.acceptBlock = { [weak self] image in
                        
                        // Accept block, using image as sender
                        // Let's download the image first if moa doesn't already have it cached..
                        
                        self?.setHudVisible(true)
                        self?.moa.onSuccess = { [weak self] fullResImage in
                            
                            self?.setHudVisible(false)
                            vc.view.removeFromSuperview()
                            
                            NSLog("Moa provided full-res image from \(image.url)")
                            self?.performSegue(withIdentifier: "applyFilter", sender: fullResImage)
                            return fullResImage
                        }
                        self?.moa.url = image.url
                    }
                    
                    vc.cancelBlock = {
                        vc.view.removeFromSuperview()
                    }
                    
                    // show the dialog, since we have a tab bar we'll need to include it as a child view rather than present it modeally,
                    // since iOS can lose the lower graphic context by switching tabs (and you end up with blackness below)
                    self.addChildViewController(vc, toContainerView: self.view)
//                    self.view.addSubview(vc.view)
                } else {
                    NSLog("Error instantiating ImageApprovalViewController from storyboard!")
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
            hudSpinner!.label.text = NSLocalizedString("Checking Server", comment: "")
            hudSpinner!.backgroundColor = UIColor(white: 0, alpha: 0.5) // dark
        } else {
            hudSpinner?.hide(animated: true)
            hudSpinner = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Not checking segue identifier, as our destination VC type is more interesting in
        // this case Note we can pass the UIImage we'll be filtering through the segue as
        // the sender, and thus prevent keeping any references to the selected image here
        // in our class
        
        if let vc = segue.destination as? ApplyFilterViewController {
            if let image = sender as? UIImage {
                vc.prepare(viewModel: ViewModelFactory.createApplyFilterViewModel(inputImage: image))
            } else {
                // Show something, but alert the programmer - something went wrong.
                vc.prepare(viewModel: ViewModelFactory.createApplyFilterViewModel(inputImage: UIImage(named: "SamplePup")!)) 
                NSLog("Error - called applyFilter segue without passing the image as sender. Showing default image.")
            }
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
