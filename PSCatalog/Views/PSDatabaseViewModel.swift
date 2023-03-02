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
    
    func streamReadingAndParse(from url: URL?, completion: @escaping (Bool) -> Void) {
        guard let url = url else { return }
        let fileReader = PSStreamFileReader(url: url)
        var items = [PSProduct(productId: "", title: "", listPrice: 0, salesPrice: 0, color: "", size: "")]
        items = []
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            defer {
                fileReader.close()
            }
            while let line = fileReader.readLine() {
                let product = PSCSVParser().parse(by: line, encoding: .utf8)
                items.append(product)
            }
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            print("parsed \(items.count) lines")
            items.removeFirst()
            completion(true)
            self.loadDataIntoDBInBatch(items)
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
    // load data in batch
    func loadDataIntoDBInBatch(_ allRecords: [PSProduct]) {
        let all = allRecords.count
        
        let loops = all / rowsPerBatch
        let deletedAll = dataStore.deleteAll()
        print("Deleted all items \(deletedAll): \(dataStore.getAllProducts().count)......")
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            var last = 0
            for i in 0..<loops {
                let start = self.rowsPerBatch * i
                let end = start + self.rowsPerBatch - 1
                let tobeLoaded = Array(allRecords[start...end])
                let (lastRow, error) = self.dataStore.insertInBatch(tobeLoaded)
                if let row = lastRow {
                    last = Int(row)
                    self.progress.value = Float(row) / Float(all)
                    print("inserted at \(row), all = \(all), progress: \(self.progress.value)")
                }
                print("load database in batch: \(lastRow ?? -1), \(error?.localizedDescription ?? "")")
            }
            
            if last < all { // if there is remainders
                let tobeLoaded = Array(allRecords[last..<all])
                print("remainder start: \(last), end: \(all-1), all: \(all)")
                let (lastRow, error) = self.dataStore.insertInBatch(tobeLoaded)
                if let row = lastRow {
                    last = Int(row)
                    self.progress.value = Float(row) / Float(all)
                    print("inserted at \(row), all = \(all), progress: \(self.progress.value)")
                }
            }
            
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.dBLoadingCompletion.value = true
            print("Database loading is finished...")
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
