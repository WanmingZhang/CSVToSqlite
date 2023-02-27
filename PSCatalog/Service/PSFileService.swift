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
protocol PSFileServiceProtocol {
    func moveFile(fromUrl url:URL,
                         toDirectory directory:String? ,
                         withName name:String) -> (Bool, Error?, URL?)
    
    func writeToDisk(fromUrl url:URL,
                     toDirectory directory:String? ,
                     withName name:String) -> (Bool, Error?, URL?)
    
    func cacheDirectoryPath() -> URL
    func createDirectoryIfNotExists(withName name:String) -> (Bool, Error?)
    func deleteFile(from directory: String, withName name: String) -> (Bool, Error?)
    func deleteFile(at path: String) -> (Bool, Error?)
}

struct PSFileService: PSFileServiceProtocol {
    // MARK:- Helpers
    func writeToDisk(fromUrl url:URL,
                     toDirectory directory:String? ,
                     withName name:String) -> (Bool, Error?, URL?) {
        
        var newUrl:URL
        if let directory = directory {
            let directoryCreationResult = self.createDirectoryURLIfNotExists(withName: directory)
            guard directoryCreationResult.0 == true else {
                return (false, directoryCreationResult.1, nil)
            }
            newUrl = self.cacheDirectoryURL().appendingPathComponent(directory).appendingPathComponent(name)

        } else {
            newUrl = self.cacheDirectoryURL().appendingPathComponent(name)
        }
        
        do {
            let content = try String(contentsOf: url as URL, encoding: .utf8)
            let data = Data(content.utf8)
            do {
                try data.write(to: newUrl, options: .atomic)
                return (true, nil, newUrl)
            } catch {
                // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                return (false, error, newUrl)
            }
        } catch let error {
            return (false, error, newUrl)
        }
    }
    
    func moveFile(fromUrl url:URL,
                         toDirectory directory:String? ,
                         withName name:String) -> (Bool, Error?, URL?) {
        var newUrl:URL
        if let directory = directory {
            let directoryCreationResult = self.createDirectoryIfNotExists(withName: directory)
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
    
    func cacheDirectoryURL() -> URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesDirectory
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
    
    func createDirectoryURLIfNotExists(withName name:String) -> (Bool, Error?)  {
        let directoryUrl = self.cacheDirectoryURL().appendingPathComponent(name)
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
    
    /// get file destination URL
    func getFileDestURL(directory: String, name: String) -> URL? {
        let directoryUrl = self.cacheDirectoryURL().appendingPathComponent(directory).appendingPathComponent(name)
        //let directoryUrl = self.cacheDirectoryURL().appendingPathComponent(name)
        return directoryUrl
    }
    
    /// delete file from known directory
    func deleteFile(from directory: String, withName name: String) -> (Bool, Error?) {
        guard let directoryUrl = getFileDestURL(directory: directory, name: name) else { return (false, nil) }
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
