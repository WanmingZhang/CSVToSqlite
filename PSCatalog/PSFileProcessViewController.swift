//
//  PSFileProcessViewController.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/23/23.
//

import UIKit

class PSFileProcessViewController: UIViewController {
    var fileURL: URL?
    
    init(fileURL: URL? = nil) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Process Catalog"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(startParseFile))
    }

    @objc func startParseFile() {
        let parser = PSCSVParser()
        guard let url = fileURL else {return}
        if let products = parser.parseCSV(contentsOfURL: url as NSURL, encoding: .utf8) {
            print("there are: \(products.count) products")
        }
        
    }


}
