//
//  PSFileServiceTests.swift
//  PSCatalogTests
//
//  Created by wanming zhang on 2/26/23.
//

import XCTest
@testable import PSCatalog

final class PSFileServiceTests: XCTestCase {
    var mockFileService : PSFileServiceProtocol?
    let testFolder = "testWriteToDisk"
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.mockFileService = MockFileService()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.mockFileService = nil
    }

    func testWriteToDisk() throws {
        guard let url = URL(string: "string") else {
            return
        }
        let (result, error, newUrl) = self.mockFileService!.writeToDisk(fromUrl: url, toDirectory: nil, withName: testFolder)
        print("test write to disk new url: \(url.absoluteString)")
        XCTAssertFalse(result)
        XCTAssertNotNil(error)
        print("write to disk should fail with error: \(error?.localizedDescription ?? "")")
    }

    func testDeleteFile() {
        let (result, error) =  self.mockFileService!.deleteFile(from: "", withName: testFolder)
        XCTAssertFalse(result)
        XCTAssertNotNil(error)
        print("delete file should fail with error: \(error?.localizedDescription ?? "")")
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
