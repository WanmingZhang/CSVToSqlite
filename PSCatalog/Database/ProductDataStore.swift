//
//  ProductDataStore.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import Foundation
import SQLite

/// A class that encapsulates the connection with SQLite.
/// Create Database and Table
/// Perform Insert and Read
/// Perform Find
/// Perform Delete

protocol PSDataStoreProtocol {
    // insert
    func insert(productId: String, title: String, listPrice: Double, salesPrice: Double, color: String, size: String) -> (Int64?, Error?)
    func insertInBatch(_ batchProducts: [PSProduct]) -> (Int64?, Error?)
    
    // query
    func filterProducts(by searchString: String, limit: Int, offset: Int) -> ([PSProduct]?, Error?)
    func loadProductsFromDatabase(_ limit: Int, _ offset: Int) -> [PSProduct]
    func getAllProducts() -> [PSProduct]
    
    // delete
    func deleteAll() -> Bool
    func delete(color: String) -> Bool
    func delete(size: String) -> Bool
}

class ProductDataStore: PSDataStoreProtocol {
    private let products = Table("products")

    private let productId = Expression<String>("productId")
    private let title = Expression<String>("title")
    private let listPrice = Expression<Double>("listPrice")
    private let salesPrice = Expression<Double>("salesPrice")
    private let color = Expression<String>("color")
    private let size = Expression<String>("size")

    static let shared = ProductDataStore()

    private var db: Connection? = nil
    
    // Create Database
    private init() {
        if let docDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let dirPath = docDir.appendingPathComponent(Constants.DIR_Product_DB)

            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let dbPath = dirPath.appendingPathComponent(Constants.STORE_NAME).path
                db = try Connection(dbPath)
                createTable()
                print("SQLiteDataStore init successfully at: \(dbPath) ")
            } catch {
                db = nil
                print("SQLiteDataStore init error: \(error)")
            }
        } else {
            db = nil
        }
    }
    
    // MARK: create table
    private func createTable() {
        guard let database = db else {
            return
        }
        do {
            try database.run(products.create { table in
                table.column(productId)
                table.column(title)
                table.column(listPrice)
                table.column(salesPrice)
                table.column(color)
                table.column(size)
            })
            print("sqlite table created...")
        } catch {
            print(error)
        }
    }
    
    // MARK: Insert
    func insertInBatch(_ batchProducts: [PSProduct]) -> (Int64?, Error?) {
        guard let database = db else {
            return (nil, nil)
        }
        var lastRow: Int64?
        var insertionError: Error?
        do {
            try database.transaction() { () -> Void in
                var lastRowId: Int64 = 0
                var setters = [[Setter]]()
                for product in batchProducts {
                    let productIdSetter: Setter = self.productId <- product.productId
                    let titleSetter: Setter = self.title <- product.title
                    let listPriceSetter = self.listPrice <- product.listPrice
                    let salesPriceSetter = self.salesPrice <- product.salesPrice
                    let colorSetter = self.color <- product.color
                    let sizeSetter = self.size <- product.size
            
                    let setter = [productIdSetter, titleSetter, listPriceSetter, salesPriceSetter, colorSetter, sizeSetter]
                    setters.append(setter)
                }
                do {
                    lastRowId = try database.run(products.insertMany(setters))
                    lastRow = lastRowId
                    print("last inserted id: \(lastRowId)")
                } catch {
                    insertionError = error
                    print("insertion failed: \(error)")
                }
            }
        } catch let error {
            print("insert in batch error: \(error.localizedDescription)")
        }
        return (lastRow, insertionError)
    }
    
    // insert one record
    func insert(productId: String, title: String, listPrice: Double, salesPrice: Double, color: String, size: String) -> (Int64?, Error?) {
        guard let database = db else {
            return (nil, nil)
        }
        
        //productId: String, title: String, listPrice: Double, salesPrice: Double, color: String, size: String
        let insert = products.insert(self.productId <- productId,
                                     self.title <- title,
                                     self.listPrice <- listPrice,
                                     self.salesPrice <- salesPrice,
                                     self.color <- color,
                                     self.size <- size)
        do {
            let rowID = try database.run(insert)
            return (rowID, nil)
        } catch {
            print("Error inserting record to database: \(error.localizedDescription)")
            return (nil, error)
        }
    }
    
    // MARK: query
    func filterProducts(by searchString: String, limit: Int, offset: Int) -> ([PSProduct]?, Error?) {
        guard let database = db else { return (nil, nil) }
        var filtered: [PSProduct]?
        let lowercased = searchString.lowercased()

        // SELECT * FROM "products" WHERE ("title" LIKE searchString)
        var filter = products.filter(productId.lowercaseString == (lowercased) || size.lowercaseString.like(lowercased) || color.lowercaseString.like(lowercased))
        filter = filter.limit(limit, offset: offset)
        do {
            for row in try database.prepare(filter) {
                let product = PSProduct(productId: row[productId],
                                        title: row[title],
                                        listPrice: row[listPrice],
                                        salesPrice: row[salesPrice],
                                        color: row[color],
                                        size: row[size])
                if filtered == nil {
                    filtered = [PSProduct]()
                    
                }
                filtered?.append(product)
            }
        } catch {
            print("query database error: \(error.localizedDescription)")
            return(nil, error)
        }
        return (filtered, nil)
    }
    
    func loadProductsFromDatabase(_ limit: Int, _ offset: Int) -> [PSProduct] {
        guard let database = db else { return [] }
        var products: [PSProduct] = []
        do {
            let query = self.products.limit(limit, offset: offset)     // LIMIT 20  OFFSET
            for product in try database.prepare(query) {
                products.append(PSProduct(productId: product[productId],
                                          title: product[title],
                                          listPrice: product[listPrice],
                                          salesPrice: product[salesPrice],
                                          color: product[color],
                                          size: product[size]))
                print("title: \(product[title]), color: \(product[color]), size: \(product[size])")
            }
        } catch {
            print(error)
        }
        return products
    }
    
    func getAllProducts() -> [PSProduct] {
        var products: [PSProduct] = []
        guard let database = db else { return [] }

        do {
            for product in try database.prepare(self.products) {
                products.append(PSProduct(productId: product[productId],
                                          title: product[title],
                                          listPrice: product[listPrice],
                                          salesPrice: product[salesPrice],
                                          color: product[color],
                                          size: product[size]))
            }
        } catch {
            print(error)
        }
        return products
    }
    
    // MARK: delete
    func deleteAll() -> Bool {
        guard let database = db else {
            return false
        }
        do {
            let filter = products.filter(self.listPrice >= 0) // always true
            try database.run(filter.delete())
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func delete(color: String) -> Bool {
        guard let database = db else {
            return false
        }
        do {
            let filter = products.filter(self.color == color)
            try database.run(filter.delete())
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func delete(size: String) -> Bool {
        guard let database = db else {
            return false
        }
        do {
            let filter = products.filter(self.size == size)
            try database.run(filter.delete())
            return true
        } catch {
            print(error)
            return false
        }
    }

}

class MockProductDataStore: PSDataStoreProtocol {
    var loadProductsFromDatabaseGotCalled = false
    var queryDatabaseGotCalled = false
    
    // insert
    func insert(productId: String, title: String, listPrice: Double, salesPrice: Double, color: String, size: String) -> (Int64?, Error?) {
        var row: Int64?
        return (row, PSCustomError.database(errorDescription: "error inserting product to database"))
    }
    func insertInBatch(_ batchProducts: [PSProduct]) -> (Int64?, Error?) {
        var row: Int64?
        return (row, PSCustomError.database(errorDescription: "error inserting product to database"))
    }
    // query
    func filterProducts(by searchString: String, limit: Int, offset: Int) -> ([PSProduct]?, Error?) {
        queryDatabaseGotCalled = true
        var filtered: [PSProduct]?
        return (filtered, PSCustomError.database(errorDescription: "error filtering products in database"))
    }
    func loadProductsFromDatabase(_ limit: Int, _ offset: Int) -> [PSProduct] {
        loadProductsFromDatabaseGotCalled = true
        let products = [PSProduct]()
        return products
    }
    
    func getAllProducts() -> [PSProduct] {
        let products = [PSProduct]()
        return products
    }
    
    // delete
    func deleteAll() -> Bool {
        return true
    }
    
    func delete(color: String) -> Bool {
        return false
    }
    
    func delete(size: String) -> Bool {
        return false
    }
}
