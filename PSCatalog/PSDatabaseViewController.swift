//
//  PSDatabaseViewController.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/23/23.
//

import UIKit

class PSDatabaseViewController: UIViewController {
    let viewModel: PSDatabaseViewModel

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    required init?(coder: NSCoder) {
        let viewModel = PSDatabaseViewModel()
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Process Catalog"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Parse", style: .plain, target: self, action: #selector(parseFile))
        setupBinder()
        configureSearchButton()
    }

    func configureSearchButton() {
        searchButton.isEnabled = false
        searchButton.layer.cornerRadius = 8.0
        updateSearchButtonState()
    }
    
    func updateSearchButtonState() {
        let products = viewModel.getAllProductsFromDB()
        self.searchButton.isEnabled = products.isEmpty ? false : true
    }
    
    // binding of view and view model
    func setupBinder() {
        viewModel.products.bind {[weak self] (_) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.viewModel.products.value.count > 0 else {
                    return
                }
                self.presentAlert()
            }
        }
        viewModel.progress.bind { [weak self] progress in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard progress > 0 else {
                    self.progressBar.progress = 0
                    self.progressLabel.text = "loading into database: 0.0 % completed"
                    return
                }
                let percentage = String(format: "%.1f %", (progress * 100))
                self.progressBar.setProgress(Float(progress), animated: true)
                self.progressLabel.text = "loading into database: \(percentage) % completed"
            }
        }
        
        viewModel.dBLoadingCompletion.bind { [weak self] completed in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if completed == true {
                    self.searchButton.isEnabled = true
                }
            }
        }
    }

    @objc func parseFile() {
        self.viewModel.parseFile()
    }
    
    func presentAlert() {
        presentAlertWithTitle(title: "", message: "Ready to load data into database", options: "Start", "Cancel") { [weak self] (option) in
            guard let self = self else { return }
            print("option: \(option)")
            switch(option) {
                case "Start":
                self.createDataStore()
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
    
    func createDataStore() {
        self.viewModel.loadDataIntoDB()
    }


    
}
