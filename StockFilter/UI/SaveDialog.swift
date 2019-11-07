//
//  SaveDialog.swift
//  StockFilter
//
//  Created by Mete Cakman on 01/10/2019.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit
import RxSwift
import FCAlertView


/// Dialog for saving a user's creation, allowing them to add a rating out of 5 and a caption
class SaveDialog: NSObject {
    
    
    // For the save dialog I'll use FCAlertDialog, because it comes with prepackaged features like ratings stars and text fields,
    // and a nice graphical layout. However, the callbacks for the text fields, ratings results, and save/cancel buttons aren't returned
    // in a single object (delegate or callback), and they aren't returned in the order you might expect (i.e. text, ratings, save/cancel).
    // They are returned in an expected order however, and there are many ways to cluster up the data, but why not  use RxSwift a little 
    // creatively here to buffer the 3 signals out of the dialog and return the results as an observable.
    
    /// Define our possible dialog results
    enum Result {
        case cancel
        case save(captionText: String, rating: Int)
    }
    
    
    /// Show the alert, return the outcome reactively
    /// - Returns: an observable that will emit (once and only once) the dialog input results
    func showAlert(title: String, subtitle: String?) -> Single<SaveDialog.Result> {
        
        return showAlertPiecewise(title: title, subtitle: subtitle)
            .buffer(timeSpan: .never, count: 3, scheduler: MainScheduler.instance) // buffer up the expected 3 responses
            .map { values -> Result in
                
                var rating = 0
                var caption = ""
                var cancelled = false
                
                for value in values {
                    switch value {
                    case .rating(let count):
                        rating = count
                    case .textField(let text):
                        caption = text
                    case .finish(let isCancelled):
                        cancelled = isCancelled
                    }
                }
                
                return cancelled ? .cancel : .save(captionText: caption, rating: rating)
            }
            .take(1)
            .asSingle()
    }
    
    
    // MARK: - Private
    
    
    /// An inner enumeration we can use for our "piecewise" result observable, before it's
    /// buffered into a single observable output
    private enum PiecewiseResult {
        case rating(count: Int)
        case textField(text: String)
        case finish(isCancelled: Bool)
    }
    
    
    /// An observable that reports all the piecewise bits of data from the dialog
    private func showAlertPiecewise(title: String, subtitle: String?) -> Observable<PiecewiseResult> {
        
        return Observable<PiecewiseResult>.create { (observer) -> Disposable in
            
            // Create our FCAlertView, give it stars, add buttons and text field which fire onNexts
            let alert = FCAlertView()
            
            alert.makeAlertTypeRateStars { (rating) in
                observer.onNext(.rating(count: rating))
            }
            
            alert.showAlert(withTitle: title, withSubtitle: subtitle, withCustomImage: nil, withDoneButtonTitle: "Save", andButtons: [])
            
            alert.addButton(NSLocalizedString("Cancel", comment: "")) {
                observer.onNext(.finish(isCancelled: true))
            }
            
            alert.doneBlock = {
                observer.onNext(.finish(isCancelled: false))
            }
            
            alert.addTextField(withPlaceholder: NSLocalizedString("Add a caption", comment: "")) { (caption) in
                observer.onNext(.textField(text: caption ?? ""))
            }
            
            return Disposables.create { }
        }
    } 
}
