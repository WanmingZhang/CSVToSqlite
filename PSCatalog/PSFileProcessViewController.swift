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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Parse", style: .plain, target: self, action: #selector(startParseFile))
    }

    @objc func startParseFile() {
        let parser = PSCSVParser()
        guard let url = fileURL else {return}
        parser.parseCSV(contentsOfURL: url as NSURL, encoding: .utf8) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self?.presentAlert()
                    print("there are: \(products?.count ?? 0) products")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func presentAlert() {
        presentAlertWithTitle(title: "", message: "Ready to load data into database", options: "Start", "Cancel") { [weak self] (option) in
            print("option: \(option)")
            switch(option) {
                case "Start":
                    print("Start button pressed")
                    break
                case "Cancel":
                    print("Cancel button pressed")
                    break
                default:
                    break
            }
        }
    }


}
