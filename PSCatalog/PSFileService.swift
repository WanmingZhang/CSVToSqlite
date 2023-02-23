//
//  PSFileService.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/22/23.
//

import Foundation

/// create a directory in the app's Library/Caches directory
/// move downloaded item from tmp  to Cache directory
///
///
protocol PSFileServiceProtocol {
    
    func moveFile(fromUrl url:URL,
                         toDirectory directory:String? ,
                         withName name:String) -> (Bool, Error?, URL?)
    func cacheDirectoryPath() -> URL
    func createDirectoryIfNotExists(withName name:String) -> (Bool, Error?)
    func deleteFile(from directory: String, withName name: String) -> (Bool, Error?)
    func deleteFile(at path: String) -> (Bool, Error?)
}

struct PSFileService: PSFileServiceProtocol {
    // MARK:- Helpers
    func moveFile(fromUrl url:URL,
                         toDirectory directory:String? ,
                         withName name:String) -> (Bool, Error?, URL?) {
        var newUrl:URL
        if let directory = directory {
            let directoryCreationResult = self.createDirectoryIfNotExists(withName: name)
            guard directoryCreationResult.0 == true else {
                return (false, directoryCreationResult.1, nil)
            }
            newUrl = self.cacheDirectoryPath().appendingPathComponent(directory).appendingPathComponent(name)
        } else {
            newUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        }
        do {
            try FileManager.default.moveItem(at: url, to: newUrl)
            return (true, nil, newUrl)
        } catch {
            return (false, error, newUrl)
        }
    }
    
    func cacheDirectoryPath() -> URL {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: cachePath)
    }
    
    func createDirectoryIfNotExists(withName name:String) -> (Bool, Error?)  {
        let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            return (true, nil)
        }
        do {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            return (true, nil)
        } catch  {
            return (false, error)
        }
    }
    /// delete file from known directory
    func deleteFile(from directory: String, withName name: String) -> (Bool, Error?) {
        let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(directory).appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: directoryUrl.path) else {
            print("File does not exist")
            return (false, nil)
        }
        do {
            let fileManager = FileManager.default
            // Delete file
            try fileManager.removeItem(atPath: directoryUrl.path)
            return (true, nil)
        }
        catch let error as NSError {
            print("An error occurred when deleting file error: \(error.localizedDescription)")
            return (false, error)
        }
    }
    
    func deleteFile(at path: String) -> (Bool, Error?) {
        //let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(directory).appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: path) else {
            print("File does not exist")
            return (false, nil)
        }
        do {
            let fileManager = FileManager.default
            // Delete file
            try fileManager.removeItem(atPath: path)
            return (true, nil)
        }
        catch let error as NSError {
            print("An error occurred when deleting file error: \(error.localizedDescription)")
            return (false, error)
        }
    }
    
}
