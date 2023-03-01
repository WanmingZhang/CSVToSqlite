//
//  PSDownloadManager.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/22/23.
//

import Foundation
//import Combine

/// PSDownloadManager is based on URLSession and URLSessionDownloadTask. It's a  an application wide singleton class and can be accessed by all parts of the app safely.
/// For the scope of the project, it focuses on background download only, and will handle only one download task.
///  This can be expanded to handle multible download tasks, parallel download, etc.

class PSDownloadManager: NSObject, ObservableObject {
    typealias ProgressClosure = ((Float) -> Void)
    typealias DownloadCompletionHandler = (_ error : Error?, _ fileUrl: URL?) -> Void
    
    static var shared = PSDownloadManager()
    private var urlSession: URLSession!
    var tasks: [URLSessionTask] = []
    private var ongoingDownloads: [String : PSDownloadItem] = [:]
    
    let fileService: PSFileServiceProtocol = PSFileService()
    
    //Make sure that the URLSession is created only once (if an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one)
    override private init() {
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        updateTasks()
    }

    public func downloadFile(withRequest request: URLRequest,
                            inDirectory directory: String? = nil,
                            withName fileName: String? = nil,
                            onProgress progressClosure:ProgressClosure? = nil,
                            onCompletion completionBlock:@escaping DownloadCompletionHandler) -> String? {
        
        guard let url = request.url else {
            debugPrint("Request url is empty")
            return nil
        }
        
        if let _ = self.ongoingDownloads[url.absoluteString] {
            debugPrint("Already in progress")
            return nil
        }
        var downloadTask: URLSessionDownloadTask
        
        downloadTask = urlSession.downloadTask(with: request)
        
        let downloadItem = PSDownloadItem(downloadTask: downloadTask,
                                          progressClosure: progressClosure,
                                        completionBlock: completionBlock,
                                        fileName: fileName,
                                        directoryName: directory)

        let key = self.getDownloadKey(withUrl: url)
        self.ongoingDownloads[key] = downloadItem
        downloadTask.resume()
        return key;
    }
    
    func getDownloadKey(withUrl url: URL) -> String {
        return url.absoluteString
    }
    
    func startDownload(url: URL) {
        let task = urlSession.downloadTask(with: url)
        task.resume()
        tasks.append(task)
    }
    
    private func updateTasks() {
        urlSession.getAllTasks { tasks in
            DispatchQueue.main.async {
                self.tasks = tasks
            }
        }
    }
}

extension PSDownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else {
            debugPrint("Could not calculate progress as totalBytesExpectedToWrite is less than 0")
            return;
        }
        if let downloadItem = self.ongoingDownloads[(downloadTask.originalRequest?.url?.absoluteString)!],
            let progressClosure = downloadItem.progressClosure {
            let progress : Float = Float(downloadTask.progress.fractionCompleted)
            DispatchQueue.main.async {
                progressClosure(progress)
            }
        }
        print("DownLoad progress: \(downloadTask.progress.fractionCompleted)")
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download finished at location: \(location.absoluteString)")
        // The file at location is temporary and will be gone afterwards
        let key = (downloadTask.originalRequest?.url?.absoluteString)!
        if let downloadItem = self.ongoingDownloads[key]  {
            guard let response = downloadTask.response else {
                // handle error
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("no response")
                return
            }
            guard case 200...299 = httpResponse.statusCode else {
                // handle error
                let error = NSError(domain:"HttpError", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)])
                OperationQueue.main.addOperation({
                    downloadItem.completionBlock(error,nil)
                })
                return
            }
            
            let fileName = downloadItem.fileName ?? downloadTask.response?.suggestedFilename ?? (downloadTask.originalRequest?.url?.lastPathComponent)!
            let directoryName = downloadItem.directoryName
            
            // if file with same name already exist, delete it then replace with new download
            let deleteResult = fileService.deleteFile(from:directoryName ?? "", withName: fileName)
            
            let fileMovingResult = fileService.moveFile(fromUrl: location, toDirectory: directoryName, withName: fileName)
            let didSucceed = fileMovingResult.0
            let error = fileMovingResult.1
            let finalFileUrl = fileMovingResult.2
            
            let progressClosure = downloadItem.progressClosure
            DispatchQueue.main.async {
                progressClosure?(1.0)
                (didSucceed ? downloadItem.completionBlock(nil,finalFileUrl) : downloadItem.completionBlock(error,nil))
            }
        }
        self.ongoingDownloads.removeValue(forKey:key)
    }

    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Download error: \(error.localizedDescription)")
        } else {
            print("Task finished: \(task.debugDescription)")
        }
    }
}



