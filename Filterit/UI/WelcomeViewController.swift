//
//  WelcomeViewController.swift
//  Filterit
//
//  Created by Mete Cakman on 29/09/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift


class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let isLandscapeAspect = view.size.width > view.size.height
        configureUi(landscape: isLandscapeAspect, animate: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        let isLandscapeAspect = size.width > size.height
        configureUi(landscape: isLandscapeAspect, animate: true)
    }
    
    /// Some differences between landscape and portrait mode need to be done
    /// programmatically, rather than using Interface Builder settings.
    /// - Parameters:
    ///   - landscape: true for landscape mode, else portrait
    ///   - animate: whether to animate changes or not. Currently unused but left in place while developing for ease!
    private func configureUi(landscape: Bool, animate: Bool) {
        // When switching to landscape, let's swivel our title stack to horizontal layout
        self.titleStackView.axis = landscape ? .horizontal : .vertical
        self.titleStackView.alignment = landscape ? .firstBaseline : .center
    }
    
    
    
    // MARK: - Development Rig for Quicker Debugging
    
    @IBAction func pressTestsButton(_ sender: Any) {
        
        // keeping old tests around, rather than overwriting them..
        let testType = 1
        
        switch testType {
        case 0: // SaveDialog test pops up dialog and outputs response
            SaveDialog().showAlert(title: "Test Save Dialog", subtitle: nil)
                //            .debug()
                .subscribe(
                    onSuccess: { (result) in
                        print("\(#function) result \(result)")
                    }, 
                    onFailure: { (error) in
                        print("\(#function) error \(error)")
                    })
                .disposed(by: disposeBag)
            
        case 1: // ApplyFilterVC early tests
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ApplyFilterViewController") as! ApplyFilterViewController
            vc.setInputImage(UIImage(named: "SamplePup")!)
            self.show(vc, sender: nil)
            
        default:
            break
        }
        
    }

}
