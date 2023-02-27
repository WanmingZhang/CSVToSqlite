//
//  PSDatabaseTests.swift
//  PSCatalogTests
//
//  Created by wanming zhang on 2/26/23.
//

import XCTest
@testable import PSCatalog

final class PSDataStoreTests: XCTestCase {

    var mockDataStore : MockProductDataStore?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.mockDataStore = MockProductDataStore()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.mockDataStore = nil
    }
    
    // insert
    func testInsertDataIntoDB() {
        let (result, error) = self.mockDataStore!.insert(productId: "", title: "", listPrice: 0.0, salesPrice: 0.0, color: "", size: "")
        XCTAssertNil(result, error?.localizedDescription ?? "")
    }
    // query
    func testgetAllProducts() throws {
        let products = self.mockDataStore?.getAllProducts()
        XCTAssertNotNil(products)
    }
    
    func testFilteringProducts() {
        let (products, error) = self.mockDataStore!.filterProducts(by: "", limit: 0, offset: 0)
        XCTAssertNil(products, error?.localizedDescription ?? "")
    }
    
    func testLoadProductsFromDB() {
        let products = self.mockDataStore?.loadProductsFromDatabase(0, 0)
        XCTAssertNotNil(products)
        XCTAssertEqual(products?.count, 0)
    }

    // delete
    func testDeleteAll() {
        let result = self.mockDataStore?.deleteAll()
        XCTAssertEqual(result, true)
    }

    func testDeleteByColorFailed() {
        let result = self.mockDataStore?.delete(color: "Green")
        XCTAssertEqual(result, false)
    }
    
    func testDeleteBySizeFailed() {
        let result = self.mockDataStore?.delete(size: "Invalid")
        XCTAssertEqual(result, false)
    }
}
