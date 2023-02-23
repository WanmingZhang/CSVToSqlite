//
//  PSDownloadViewController.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/22/23.
//

import UIKit
import Combine

class PSDownloadViewController: UIViewController {
    
    private var subscriptions: AnyCancellable?
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
        deleteFileFromDiskForDemo()
    }
    
    // for demo purpose, delete file from disk the first time we load the view
    func deleteFileFromDiskForDemo() {
        let fileService = PSFileService()
        let deleteResult = fileService.deleteFile(from: Constants.directoryName, withName: Constants.fileName)
        print("delete file for demo purposes: \(deleteResult.0)")
    }
    
    func setupView() {
        urlLabel.text = ""
        finalUrlLabel.text = ""
        progressBar.progress = 0
        progressLabel.text = "0.0 %"
    }
    
    @objc func startDownload() {
        progressBar.progress = 0
        progressLabel.text = "0.0 %"
        guard let url = URL(string: Constants.catalogfileURL) else { return }
        let request = URLRequest(url: url)
        urlLabel.text = request.url?.absoluteString ?? "-"
        let downloadKey = self.downloadManager.downloadFile(withRequest: request,
                                                            inDirectory: Constants.directoryName,
                                                            withName: Constants.fileName,
                                                            onProgress:  { [weak self] (progress) in
            guard let self = self else { return }
            let percentage = String(format: "%.1f %", (progress * 100))
            self.progressBar.setProgress(Float(progress), animated: true)
            self.progressLabel.text = "\(percentage) % completed"
        }) { [weak self] (error, url) in
            guard let self = self else { return }
            if let error = error {
                print("Error is \(error.localizedDescription)")
                self.finalUrlLabel.text = error.localizedDescription
            } else {
                if let url = url {
                    print("Downloaded file's url is \(url.path)")
                    self.finalUrlLabel.text = "File saved at: \(url.path)"
                }
            }
        }
        
        print("The key is \(downloadKey!)")
    }

}
