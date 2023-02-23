//
//  PSDownloadItem.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/22/23.
//

import Foundation

class PSDownloadItem: NSObject {

    var completionBlock: PSDownloadManager.DownloadCompletionHandler
    var progressClosure: PSDownloadManager.ProgressClosure?
    let downloadTask: URLSessionDownloadTask
    let directoryName: String?
    let fileName:String?
    
    init(downloadTask: URLSessionDownloadTask,
         progressClosure: PSDownloadManager.ProgressClosure?,
         completionBlock: @escaping PSDownloadManager.DownloadCompletionHandler,
         fileName: String?,
         directoryName: String?) {
        
        self.downloadTask = downloadTask
        self.completionBlock = completionBlock
        self.progressClosure = progressClosure
        self.fileName = fileName
        self.directoryName = directoryName
    }
    
}
