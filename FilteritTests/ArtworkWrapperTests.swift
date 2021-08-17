//
//  ArtworkWrapperTests.swift
//  FilteritTests
//
//  Created by Mete Cakman on 6/12/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import XCTest
import CoreData
import RxSwift
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
        // Clear database between tests
        if let artworks = try? ArtworkWrapper.fetchAll() {
            artworks.forEach { try! $0.remove() }
        }
    }

    /// Test artwork creation and fetch methods
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
            fetch = try ArtworkWrapper.fetchAll(orderByCreatedDate: true)
            XCTAssertEqual(fetch.count, 2)
            
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
            
            // Note - testing equality by comparing image sizes is a slightly weak test, however since there may be JPEG compression happening at the point of storing the image to the filesystem, we can't test byte for byte. And no sense testing pixel by pixel here at all, failed image storage would be obvious running the app.
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }

    func testArtworkDeletion() {
        // Create 1 Artwork object, store it, then remove it again
        let testImage = UIImage(named: "SamplePup")!
        let now = Date()
        let artwork1 = ArtworkWrapper(caption: "3", image: testImage, created: now, rating: 1)
        
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
            XCTFail("ERROR: \(error)")
        }
    }
    
    // test the reactive fetch method 
    func testFetchAllRx() {
        continueAfterFailure = false
        
        // initial test for zero entries
        let _ = ArtworkWrapper.fetchAllRx().subscribe(
            onSuccess: { response in
                XCTAssertEqual(response.count, 0)
        }, 
            onFailure: { error in
                XCTFail("Failed with error thrown \(error)")
        })
        
        let testImage = UIImage(named: "SamplePup")!
        let now = Date()
        let later = Date(timeInterval: 100, since: now)
        let before = Date(timeInterval: -100, since: now)
        
        let artwork1 = ArtworkWrapper(caption: "4", image: testImage, created: now, rating: 1)
        let artwork2 = ArtworkWrapper(caption: "5", image: testImage, created: later, rating: 2)
        let artwork3 = ArtworkWrapper(caption: "6", image: testImage, created: before, rating: 3)
        
        guard let _ = try? artwork1.save(), 
              let _ = try? artwork2.save(), 
              let _ = try? artwork3.save() else {
            XCTFail("Failed to save artwork")
            return
        }
        
        // Now expect our 2 entries
        let _ = ArtworkWrapper.fetchAllRx().subscribe(
            onSuccess: { response in
                XCTAssertEqual(response.count, 3)
        }, 
            onFailure: { error in
                XCTFail("Failed with error thrown \(error)")
        })
        
        // Do the same but test ordering it by created date
        let _ = ArtworkWrapper.fetchAllRx(orderByCreatedDate: true).subscribe(
            onSuccess: { response in
                XCTAssertEqual(response.count, 3)
                XCTAssertEqual(response[0].rating, 3)
                XCTAssertEqual(response[1].rating, 1)
                XCTAssertEqual(response[2].rating, 2)
                XCTAssertEqual(response[0].caption, "6")
                XCTAssertEqual(response[1].caption, "4")
                XCTAssertEqual(response[2].caption, "5")
        }, 
            onFailure: { error in
                XCTFail("Failed with error thrown \(error)")
        })
    }
    
    
    // MARK:- Test rig for mocked persistent data stores
    
    /// Create a mock persistent CoreData container to inject into ArtworkWrapper, from
    /// which we'll read/write data. This container will be stored in memory so we don't
    /// need to erase anything between test runs.
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
