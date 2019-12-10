//
//  ArtworkWrapperTests.swift
//  FilteritTests
//
//  Created by Mete Cakman on 6/12/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import XCTest
import CoreData
@testable import Filterit

class ArtworkWrapperTests: XCTestCase {

    // class variety of setUp() just runs once per test suite.. inject a mock CoreData container here
    override class func setUp() {
        super.setUp()
        
        ArtworkWrapper.persistentContainer = ArtworkWrapperTests.mockPersistentContainer
    }
    
    override func setUp() {
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // Clear database
        if let artworks = try? ArtworkWrapper.fetchAll() {
            artworks.forEach { try! $0.remove() }
        }
    }

    func testArtworkCreation() {
        // Create 2 new artwork objects, save them, make sure they're there.
        // Meanwhile create 1 without saving it, and make sure it's not there.
        let testImage = UIImage(named: "SamplePup")!
        let now = Date()
        let later = Date(timeInterval: 100, since: now)
        
        let artwork1 = ArtworkWrapper(caption: "1", image: testImage, created: now, rating: 1)
        let artwork2 = ArtworkWrapper(caption: "2", image: testImage, created: later, rating: 2)
        let _ = ArtworkWrapper(caption: "3", image: testImage, created: later, rating: 3)
        
        do {
            var fetch = try ArtworkWrapper.fetchAll()
            XCTAssertEqual(fetch.count, 0)
        
            try artwork1.save()
            fetch = try ArtworkWrapper.fetchAll()
            XCTAssertEqual(fetch.count, 1)
            
            try artwork2.save()
            fetch = try ArtworkWrapper.fetchAll()
            XCTAssertEqual(fetch.count, 2)
            
            // order fetched results for consistent testing
            fetch = fetch.sorted(by: { $0.created < $1.created })
            let savedArtwork1 = fetch[0]
            let savedArtwork2 = fetch[1]
            
            XCTAssertEqual(savedArtwork1.caption, "1")
            XCTAssertEqual(savedArtwork1.rating, 1)
            XCTAssertEqual(savedArtwork1.created, now)
            XCTAssertEqual(savedArtwork1.image!.size, testImage.size)
            XCTAssertEqual(savedArtwork2.caption, "2")
            XCTAssertEqual(savedArtwork2.rating, 2)
            XCTAssertEqual(savedArtwork2.created, later)
            XCTAssertEqual(savedArtwork2.image!.size, testImage.size)
            
            // Note - testing equality by compariing image sizes is a slightly weak test, however since there may be JPEG compression happening at the point of storing the image to the filesystem, we can't test byte for byte. And no sense testing pixel by pixel here at all, failed image storage would be obvious running the app.
        } catch {
            print("ERROR: %@", error)
            XCTFail()
        }
    }

    func testArtworkDeletion() {
        // Create 1 Artwork object, store it, then remove it again
        let testImage = UIImage(named: "SamplePup")!
        let now = Date()
        let artwork1 = ArtworkWrapper(caption: "1", image: testImage, created: now, rating: 1)
        
        do {
            var fetch = try ArtworkWrapper.fetchAll()
            XCTAssertEqual(fetch.count, 0)
            
            try artwork1.save()
            fetch = try ArtworkWrapper.fetchAll()
            XCTAssertEqual(fetch.count, 1)
            
            try artwork1.remove()
            fetch = try ArtworkWrapper.fetchAll()
            XCTAssertEqual(fetch.count, 0)
            
        } catch {
            print("ERROR: %@", error)
            XCTFail()
        }
    }
    
    
    // MARK:- Test rig for mocked persistent data stores
    
    /// Create a mock persistent CoreData container to inject into ArtworkWrapper, from which we'll read/write
    /// data. This container will be stored in memory so we don't need to erase anything between test runs.
    static var mockPersistentContainer: NSPersistentContainer = {
        
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: ArtworkWrapperTests.self)] )!
        let container = NSPersistentContainer(name: "Filterit", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            if error != nil {
                fatalError("Failed to create our mock persistent container \(error!)")
            }
        }
        
        return container
    }()
}
