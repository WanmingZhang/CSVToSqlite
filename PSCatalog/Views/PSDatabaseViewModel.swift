//
//  PSDatabaseViewModel.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import Foundation

class PSDatabaseViewModel {
    var products: Observable<[PSProduct]> = Observable([])
    var errorMsg: Observable<String?> = Observable(nil)
    var progress: Observable<Float> = Observable(0)
    var dBLoadingCompletion: Observable<Bool> = Observable(false)
    let dataStore: PSDataStoreProtocol
    let rowsPerBatch = 1000
    
    init(_ dataStore: PSDataStoreProtocol) {
        self.dataStore = dataStore
    }
    /// parse entire file using CSV parser
    /// no longered preferred since stream reading is preferred
    func parseFile() {
        let parser = PSCSVParser()
        guard let url = getFileURL() else {return}
        parser.parseCSV(contentsOfURL: url as NSURL, encoding: .utf8) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    guard let products = products else {
                        return
                    }
                    self.products.value = products
                    print("there are: \(products.count) products")
                case .failure(let error):
                    self.errorMsg.value = error.localizedDescription
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getNumOflines(from url: URL?) -> Int {
        guard let url = url else { return 0}
        let fileReader = PSStreamFileReader(url: url)
        var count = 0
        while fileReader.readLine() != nil {
            count += 1
        }
        return count
    }
    
    func streamReadingAndParse(from url: URL?, _ totalLines: Int, completion: @escaping (Bool) -> Void) {
        guard let url = url else { return }
        let fileReader = PSStreamFileReader(url: url)
        var items = [PSProduct(productId: "", title: "", listPrice: 0, salesPrice: 0, color: "", size: "")]
        items = []
        let deletedAll = dataStore.deleteAll()
        print("Deleted all items \(deletedAll): \(dataStore.getAllProducts().count)......")
        let numOfIterations = totalLines / rowsPerBatch
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            defer {
                fileReader.close()
            }
            for _ in 0..<numOfIterations {
                var count = 0
                items = []
                while count < self.rowsPerBatch {
                    if let line = fileReader.readLine() {
                        let product = PSCSVParser().parse(by: line, encoding: .utf8)
                        if product.productId == "productId" || product.title == "title" {
                            continue
                        }
                        items.append(product)
                        count += 1
                    }
                }
                self.loadDataInBatch(items, totalLines-1) // skip the title line
            }
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            print("parsed \(items.count) lines")
            self.dBLoadingCompletion.value = true
            print("Database loading is finished...")
            completion(true)
            //self.loadDataIntoDBInBatch(items)
        }
    }
    
    func getFileURL() -> URL? {
        let fileService = PSFileService()
        let directoryUrl = fileService.getFileDestURL(directory: Constants.DIR_CATALOG, name: Constants.FILE_NAME)
        return directoryUrl
    }
    
    func getAllProductsFromDB() -> [PSProduct] {
        return dataStore.getAllProducts()
    }
    
    func loadDataInBatch(_ batch: [PSProduct], _ totalLines: Int) {
        
        let (lastRow, error) = self.dataStore.insertInBatch(batch)
        if let row = lastRow {
            self.progress.value = Float(row) / Float(totalLines)
            print("inserted at \(row), totalLines = \(totalLines), progress: \(self.progress.value)")
        }
    }
    
    // load the entire file into database all at once
    func loadDataIntoDB() {
        let db = ProductDataStore.shared
        var all = self.products.value
        guard !all.isEmpty else { return }
        all.removeFirst()
        let deletedAll = db.deleteAll()
        print("Deleted all items \(deletedAll): \(db.getAllProducts().count)......")
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            for product in all {
                let result = db.insert(productId: product.productId,
                                       title: product.title,
                                       listPrice: product.listPrice,
                                       salesPrice: product.salesPrice,
                                       color: product.color,
                                       size: product.size)

                if let row = result.0 {
                    self.progress.value = Float(row) / Float(all.count)
                    print("inserted at \(row), all = \(all.count), progress: \(self.progress.value)")
                }
            }
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            self.dBLoadingCompletion.value = true
            print("Database loading is finished...")
        }
    }
}
