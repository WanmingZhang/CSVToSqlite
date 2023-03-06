//
//  PSDownloadViewController.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/22/23.
//

import UIKit
import Combine

class PSDownloadViewController: UIViewController {
    
    var downloadManager = PSDownloadManager.shared

    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var finalUrlLabel: UILabel!
    @IBOutlet weak var processButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Download Catalog"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(startDownload))
        setupView()
    }
    
    func setupView() {
        urlLabel.text = ""
        finalUrlLabel.text = ""
        progressBar.progress = 0
        progressLabel.text = "0.0 %"
        processButton.layer.cornerRadius = 8.0
        updateProcessButton()
    }
    
    @objc func startDownload() {
        progressBar.progress = 0
        progressLabel.text = "0.0 %"
        guard let url = URL(string: Constants.CATALOG_FILE_URL) else { return }
        let request = URLRequest(url: url)
        urlLabel.text = "Download from: \(request.url?.absoluteString ?? "-")"
        let downloadKey = self.downloadManager.downloadFile(withRequest: request,
                                                            inDirectory: Constants.DIR_CATALOG,
                                                            withName: Constants.FILE_NAME,
                                                            onProgress:  { [weak self] (progress) in
            guard let self = self else { return }
            let percentage = String(format: "%.1f %", (progress * 100))
            self.progressBar.setProgress(Float(progress), animated: true)
            self.progressLabel.text = "\(percentage) % completed"
        }) { [weak self] (error, url) in
            guard let self = self else { return }
            if let error = error {
                print("Error is \(error.localizedDescription)")
                self.updateProcessButton()
                self.handleDownloadCompletionError(error, url)
            } else {
                if let url = url {
                    print("Downloaded file's url is \(url.path)")
                    self.finalUrlLabel.text = "File saved at: \(url.path)"
                    self.updateProcessButton()
                }
            }
        }
        print("The key is \(downloadKey ?? "")")
    }
    
    func updateProcessButton() {
        let fileService = PSFileService()
        guard let directoryUrl = fileService.getFileDestURL(directory: Constants.DIR_CATALOG, name: Constants.FILE_NAME) else { return }
        
        guard FileManager.default.fileExists(atPath: directoryUrl.path) else {
            print("File does not exist")
            return
        }
        processButton.isEnabled = true
    }
    
    func handleDownloadCompletionError(_ error : Error, _ fileUrl: URL?) {
        let errorCode = (error as NSError).code
        if errorCode == 516 { //"File exists"
            presentAlert()
        }
        
        self.finalUrlLabel.text = error.localizedDescription
    }
    
    func presentAlert() {
        presentAlertWithTitle(title: "", message: "A file with the same name already exists", options: "Delete", "Cancel") { [weak self] (option) in
            print("option: \(option)")
            switch(option) {
                case "Delete":
                self?.deleteAndRedownload()
                    print("Delete button pressed")
                    break
                case "Cancel":
                    print("Cancel button pressed")
                    break
                default:
                    break
            }
        }
    }
    
    func deleteAndRedownload() {
        let fileService = PSFileService()
        let deleteResult = fileService.deleteFile(from:Constants.DIR_CATALOG, withName: Constants.FILE_NAME)
        print("delete file: \(deleteResult.0)")
        if deleteResult.0 == true {
            //self.startDownload()
        }
    }
    
}
