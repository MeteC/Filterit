//
//  FilterTests.swift
//  StockFilterTests
//
//  Created by Mete Cakman on 10/10/2019.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import XCTest
@testable import StockFilter

class FilterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Make sure each FilterType provides the expected CIFilter, and that apply() provides a valid UIImage
    func testFilters() {
        let testImage: UIImage! = UIImage(named: "SamplePup")
        XCTAssertNotNil(testImage)
        
        for filterType in FilterType.allCases {
            print("Testing filter type \(filterType)")
            
            if filterType == .none {
                // none case should have a nil filter, and pass-through effect on the image
                XCTAssertNil(filterType.filter)
                XCTAssertEqual(testImage, filterType.apply(to: testImage))
            } else {
                // other filters should have non-nil filter and non-nil image output
                XCTAssertNotNil(filterType.filter)
                
                let outputImage = filterType.apply(to: testImage)
                XCTAssertNotNil(outputImage)
                XCTAssertNotEqual(testImage, outputImage)
            }
        }
    }


}
