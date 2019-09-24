//
//  CommsTests.swift
//  StockFilterTests
//
//  Created by Mete Cakman on 24/09/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import XCTest
import RxSwift
@testable import StockFilter

class CommsTests: XCTestCase {

    let rxDisposeBag = DisposeBag()
    
    override func setUp() {
    }

    override func tearDown() {
    }
    
    /// Test the API Manager listPhotos endpoint, mocking the json data provided to the APIManager class using dependency injection.
    func testListPhotos() {
        continueAfterFailure = false
        
        // Mock caller injection - inject expected API response into the APIManager rather than depend on the network for testing
        class MockCaller: APICaller {
            func pullAPIData(from request: URLRequest) -> Observable<Data> {
                let returnJson = [
                    "images": [[
                        "id": 100,
                        "thumb_url": "test_thumb_url",
                        "url": "test_url",
                        "title": "test_title",
                        "author": "test_author",
                        "updated": "2019-09-24 12:48:00"
                    ]]
                ]
                let mockResultsData = try! JSONSerialization.data(withJSONObject: returnJson, options: [])
                
                return Single<Data>.create { (single) -> Disposable in
                    single(.success(mockResultsData))
                    return Disposables.create()
                    }.asObservable()
            }
        }
        
        let apiMgr = APIManager()
        apiMgr.apiCaller = MockCaller()
        
        let response = apiMgr.listImages()
        let expect = expectation(description: "Wait for API")
        
        response.subscribe(onNext: { (images) in
            XCTAssertEqual(images.count, 1)
            XCTAssertEqual(images.first!.id, 100)
            XCTAssertEqual(images.first!.thumbUrl, "test_thumb_url")
            XCTAssertEqual(images.first!.url, "test_url")
            XCTAssertEqual(images.first!.title, "test_title")
            XCTAssertEqual(images.first!.author, "test_author")
            XCTAssertEqual(images.first!.updated, "2019-09-24 12:48:00")
            expect.fulfill()
        }, onError: { (error) in
            XCTFail("\(error)")
        })
        .disposed(by: rxDisposeBag)
        
        wait(for: [expect], timeout: 1.0)
    }
    
    /// Integration test, pulling photo list from API.
    /// As I control the static data the API provides, this is an easy test to make (I know what to expect.) 
    /// In the normal case network integration tests can be more difficult to set up as future-proof tests!
    func testIntegration_ListPhotos() {
        continueAfterFailure = false
        let apiMgr = APIManager()
        
        APIManager.clearCookies()
        
        let response = apiMgr.listImages()
        let expect = expectation(description: "Wait for API")
        
        response.subscribe(onNext: { (images) in
            XCTAssertGreaterThanOrEqual(images.count, 1)
            XCTAssertEqual(images.first!.id, 1)
            XCTAssertEqual(images.first!.thumbUrl, "https://MeteC.github.io/StockFilter/server/img/thumbnail/backlit-dawn-fog-2088210.jpg")
            XCTAssertEqual(images.first!.url, "https://MeteC.github.io/StockFilter/server/img/fullsize/backlit-dawn-fog-2088210.jpg")
            XCTAssertEqual(images.first!.title, "Silhouette of Mountain")
            XCTAssertEqual(images.first!.author, "Eberhard Grossgasteiger @ Pexels.com")
            XCTAssertEqual(images.first!.updated, "2019-09-24 12:48:00")
            expect.fulfill()
        }, onError: { (error) in
            XCTFail("\(error)")
        })
        .disposed(by: rxDisposeBag)
        
        wait(for: [expect], timeout: 10.0)
    }

}
