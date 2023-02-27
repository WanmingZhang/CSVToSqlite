//
//  PSSearchViewModelTests.swift
//  PSCatalogTests
//
//  Created by wanming zhang on 2/27/23.
//

import XCTest
@testable import PSCatalog

final class PSSearchViewModelTests: XCTestCase {
    var mockDataStore : MockProductDataStore?
    var viewModel: PSSearchViewModel?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.mockDataStore = MockProductDataStore()
        self.viewModel = PSSearchViewModel(mockDataStore!)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.mockDataStore = nil
        self.viewModel = nil
    }

    func testLoadProductsFromDatabase() {
        self.viewModel?.loadProductsFromDatabase(0)
        XCTAssertTrue(self.mockDataStore!.loadProductsFromDatabaseGotCalled)
    }
    
    func testLoadMoreFromDatabase() {
        self.viewModel?.loadMoreFromDatabase(0, 0)
        XCTAssertTrue(self.mockDataStore!.loadProductsFromDatabaseGotCalled)
    }
    
    func testQueryDatabase() {
        self.viewModel?.queryDatabase("search", 0)
        XCTAssertTrue(self.mockDataStore!.queryDatabaseGotCalled)
    }
    
    func testloadMoreQueryFromDatabase() {
        self.viewModel?.loadMoreQueryFromDatabase("search more", 0, 0)
        XCTAssertTrue(self.mockDataStore!.queryDatabaseGotCalled)
    }
    

}
