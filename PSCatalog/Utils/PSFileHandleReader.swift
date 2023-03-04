//
//  PSFileHandleReader.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/28/23.
//

import Foundation

class PSFileHandleReader {
    var fileHandle: FileHandle?
    var buffer: Data
    let bufferSize: Int = 1024
    
    // Using new line as the delimiter
    let delimiter = "\n".data(using: .utf8)!
    
    init(url: URL) {
        do {
            fileHandle = try FileHandle(forReadingFrom: url)
        } catch let error {
            print("error creating stream file reader: \(error.localizedDescription)")
        }
        buffer = Data(capacity: bufferSize)
    }
    
    init(path: String) {
        fileHandle = FileHandle(forReadingAtPath: path)
        buffer = Data(capacity: bufferSize)
    }
    
    func readLine() -> String? {
        var rangeOfDelimiter = buffer.range(of: delimiter)
        
        while rangeOfDelimiter == nil {
            guard let chunk = fileHandle?.readData(ofLength: bufferSize) else { return nil }
            
            if chunk.count == 0 {
                if buffer.count > 0 {
                    defer { buffer.count = 0 }
                    
                    return String(data: buffer, encoding: .utf8)
                }
                
                return nil
            } else {
                buffer.append(chunk)
                rangeOfDelimiter = buffer.range(of: delimiter)
            }
        }
        
        let rangeOfLine = 0 ..< rangeOfDelimiter!.upperBound
        let line = String(data: buffer.subdata(in: rangeOfLine), encoding: .utf8)
        
        buffer.removeSubrange(rangeOfLine)
        
        return line?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}
