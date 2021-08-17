//
//  ArtworkWrapper.swift
//  Filterit
//
//  Created by Mete Cakman on 5/12/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import UIKit
import CoreData
import RxSwift

/// A wrapper for using our CoreData `Artwork` entity more tightly without too much CoreData code floating around the project
class ArtworkWrapper {
    
    // Attributes
    public var caption: String?
    public var image: UIImage?
    public var created: Date
    public var rating: Int16
    
    /// The managed `Artwork` object being wrapped up
    private var artworkEntity: Artwork?
    
    /// Our persistent container. In app this will be taken from our AppDelegate,
    /// while for testing we'll inject another, hence `public static`.
    public static var persistentContainer: NSPersistentContainer?
    
    /// Retrieve our CoreData context. This is an example of a fairly unsafe method, but it can be treated as assertions on 100% expected behaviour.
    private static var managedContext: NSManagedObjectContext {
        if ArtworkWrapper.persistentContainer == nil {
            // Lazy configuration - for tests make sure you've set the persistent container before you call any other ArtworkWrapper code, or this will break and fail your tests
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            ArtworkWrapper.persistentContainer = appDelegate.persistentContainer
        }
        
        // note this will work on the main thread
        return ArtworkWrapper.persistentContainer!.viewContext
    }
    
    /// Construct a brand new Artwork wrapper
    init(caption: String, image: UIImage, created: Date, rating: Int16) {
        
        self.caption = caption
        self.image = image
        self.created = created
        self.rating = rating
        
        // don't create a managed CoreData object until we want to save to DB
    }
    
    /// Construct an Artwork wrapper from a managed object from CoreData 
    init(managedObject: Artwork) {
        self.artworkEntity = managedObject
        
        self.caption = managedObject.caption
        self.rating  = managedObject.rating
        
        // note: created is non-optional in the CoreData schema, but the autogen Artwork code is optional
        self.created = managedObject.created ?? Date()
        
        if let imageData = managedObject.image {
            self.image = UIImage(data: imageData)
        }
    }
    
    /// Commit to CoreData as a new `Artwork` entity, or overwrite if it already exists there.
    public func save() throws {
        let managedContext = ArtworkWrapper.managedContext
        
        if self.artworkEntity == nil {
            // We have no managed object instance yet so create a new one (i.e. a new database entry)
            self.artworkEntity = Artwork(context: managedContext)
        }
        
        if self.writeToManagedObject() {
            try managedContext.save() // not super necessary but ensure data is saved
        }
    }
    
    /// Remove the `Artwork` entity from CoreData, if possible. Throws error if the object can't be deleted - in our very simple DB case, this should never happen. 
    public func remove() throws {
        let managedContext = ArtworkWrapper.managedContext
        
        if self.artworkEntity == nil {
            // Can't remove, as we're not in the DB to begin with
            NSLog("WARN: Can't remove ArtworkWrapper with caption '\(self.caption ?? "<no caption>")' - not yet stored in DB")
        } else {
            try self.artworkEntity!.validateForDelete()
            managedContext.delete(self.artworkEntity!)
        }
    }
    
    /// Write wrapped properties to our managed object
    private func writeToManagedObject() -> Bool {
        guard let object = self.artworkEntity else {
            NSLog("ERROR: ArtworkWrapper can't write to nil managed object")
            return false
        }
        
        object.caption  = self.caption
        object.created  = self.created
        object.rating   = self.rating
        object.image    = self.image?.jpegData(compressionQuality: 1.0)
        
        return true
    }
    
    /// Simple fetch method retrieves all stored `Artwork` entities
    /// - Parameter orderByCreatedDate: Set true to order the results by created date (ascending)
    public static func fetchAll(orderByCreatedDate: Bool = false) throws -> [ArtworkWrapper] {
        
        let fetchRequest: NSFetchRequest<Artwork> = Artwork.fetchRequest()
        let objects = try managedContext.fetch(fetchRequest)
        
        let fetch = objects.map {
            ArtworkWrapper(managedObject: $0)
        }
        
        if orderByCreatedDate {
            return fetch.sorted(by: { $0.created < $1.created })
        } else {
            return fetch
        }
    }
    
    /// Reactive version of the fetch method, retrieves all stored `Artwork` entities
    /// and returns them as a Single observable. Note method doesn't throw, Single will
    /// error instead.
    /// - Parameter orderByCreatedDate: Set true to order the results by created date (ascending)
    public static func fetchAllRx(orderByCreatedDate: Bool = false) -> Single<[ArtworkWrapper]> {
        return Single.create { observer in
            do {
                let fetchRequest: NSFetchRequest<Artwork> = Artwork.fetchRequest()
                let objects = try managedContext.fetch(fetchRequest)
                let fetch = objects.map { ArtworkWrapper(managedObject: $0) }
                
                if orderByCreatedDate {
                    observer(.success(fetch.sorted(by: { $0.created < $1.created })))
                } else {
                    observer(.success(fetch))
                }
                
            } catch {
                observer(.failure(error))
            }
            
            return Disposables.create()
        }
    }
}
