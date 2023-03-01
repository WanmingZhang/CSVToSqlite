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
    
    func streamReadingAndParse(from url: URL?) {
        guard let url = url else { return }
        let fileReader = StreamFileReader(url: url)
        var items = [PSProduct(productId: "", title: "", listPrice: 0, salesPrice: 0, color: "", size: "")]
        items = []
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            
            while let line = fileReader.readLine() {
                let product = PSCSVParser().parse(by: line, encoding: .utf8)
                items.append(product)
                //print("line from fileReader: \(line))")
            }
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            self.products.value = items
            print("parsed \(items.count) lines")
        }
    }
    
    func getFileURL() -> URL? {
        let fileService = PSFileService()
        let directoryUrl = fileService.getFileDestURL(directory: Constants.DIR_CATALOG, name: Constants.FILE_NAME)
        return directoryUrl
    }
    
    func getAllProductsFromDB() -> [PSProduct] {
        let db = ProductDataStore.shared
        return db.getAllProducts()
    }
    // load data in batch
    func loadDataIntoDB(inBatch numOfRows: Int) {
        var count = 0
        var start = numOfRows * count
        var end = start + numOfRows - 1
        
        let db = ProductDataStore.shared
        var all = self.products.value
        guard !all.isEmpty else { return }
        all.removeFirst()
        let deletedAll = db.deleteAll()
        print("Deleted all items \(deletedAll): \(db.getAllProducts().count)......")
        
        let tobeLoaded = Array(all[start...end])
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            let (lastRow, error) = db.insertInBatch(tobeLoaded)
            if let row = lastRow {
                self.progress.value = Float(row) / Float(numOfRows)
                print("inserted at \(row), all = \(numOfRows), progress: \(self.progress.value)")
            }
            print("load database in batch: \(lastRow ?? -1), \(error?.localizedDescription ?? "")")
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
