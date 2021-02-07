//
//  FilterTests.swift
//  FilteritTests
//
//  Created by Mete Cakman on 10/10/2019.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import XCTest
@testable import Filterit


class FilterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Make sure each FilterType creates a non-nil image output.
    /// At this point we can't test actual filter results but this will provide
    /// a fail-safe for failing filters at least.
    func testFilters() {
        let testImage: UIImage! = UIImage(named: "SamplePup")
        XCTAssertNotNil(testImage)
        
        for filterType in FilterList.values {
            print("Testing filter type \(filterType)")
            
            let outputImage = filterType.apply(to: testImage)
            XCTAssertNotNil(outputImage)
            
            // TODO: What?? Why does this happen when we use FilterList.values, but NOT when we use values declared in this test file??
            if filterType is NoneFilter {
                // none case should have a total pass-through effect on the image
                print("xxxx")
                XCTAssertEqual(testImage, filterType.apply(to: testImage))
            } 
        }
    }

}
