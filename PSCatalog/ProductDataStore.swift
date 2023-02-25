//
//  ProductDataStore.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import Foundation
import SQLite

class ProductDataStore {
    private let products = Table("products")

    private let productId = Expression<String>("productId")
    private let title = Expression<String>("title")
    private let listPrice = Expression<Double>("listPrice")
    private let salesPrice = Expression<Double>("salesPrice")
    private let color = Expression<String>("color")
    private let size = Expression<String>("size")

    static let shared = ProductDataStore()

    private var db: Connection? = nil
    
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
    func filterProducts(by searchString: String) -> ([PSProduct]?, Error?) {
        guard let database = db else { return (nil, nil) }
        var filtered: [PSProduct] = []
        let lowercased = searchString.lowercased()

        // SELECT * FROM "products" WHERE ("title" LIKE searchString)
        let filter = products.filter(title.lowercaseString.like(lowercased) || size.lowercaseString.like(lowercased) || color.lowercaseString.like(lowercased))
        do {
            for row in try database.prepare(filter) {
                let product = PSProduct(productId: row[productId],
                                        title: row[title],
                                        listPrice: row[listPrice],
                                        salesPrice: row[salesPrice],
                                        color: row[color],
                                        size: row[size])
                filtered.append(product)
            }
        } catch {
            print("query database error: \(error.localizedDescription)")
            return(nil, error)
        }
        return (filtered, nil)
    }
    
    // MARK: access
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

//    func getTask() {
//        task = TaskDataStore.shared.findTask(taskId: id)
//        taskName = task?.name ?? ""
//        approxDate = task?.date ?? Date()
//        status = task!.status ? "Completed" : "Incomplete"
//    }
}
