//
//  PSFileParseTests.swift
//  PSCatalogTests
//
//  Created by wanming zhang on 2/28/23.
//

import XCTest
@testable import PSCatalog

final class PSFileParseTests: XCTestCase {
    var fileParser : PSCSVParser?
    
    override func setUpWithError() throws {
        fileParser = PSCSVParser()
    }

    override func tearDownWithError() throws {
        fileParser = nil
    }

    func testParseCSVByLine() throws {
        let testData = "99000026100002,XY Prep Short-WHT,24.99,24.99,White,MD"
        let product = fileParser?.parseCSV(line: testData, encoding: .utf8)
        XCTAssertEqual("99000026100002", product?.productId)
        XCTAssertEqual("XY Prep Short-WHT", product?.title)
        XCTAssertEqual(24.99, product?.listPrice)
        XCTAssertEqual(24.99, product?.salesPrice)
        XCTAssertEqual("White", product?.color)
        XCTAssertEqual("MD", product?.size)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
