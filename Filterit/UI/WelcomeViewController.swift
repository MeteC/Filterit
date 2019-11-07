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

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    
    
    
    // MARK: - Development Rig
    
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
                            onError: { (error) in
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
