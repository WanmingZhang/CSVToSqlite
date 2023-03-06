//
//  PSInputStreamReader.swift
//  PSCatalog
//
//  Created by wanming zhang on 3/3/23.
//

import Foundation

class PSInputStreamReader {
    var inputStream: InputStream?
    var buffer: Data
    let bufferSize: Int = 1024
    
    // Using new line as the delimiter
    let delimiter = "\n".data(using: .utf8)!
    
    init(_ data: Data) {
        inputStream = InputStream(data: data)
        inputStream?.open()
        buffer = Data(capacity: bufferSize)
    }
    
    init(_ url: URL) {
        inputStream = InputStream(url: url)
        inputStream?.open()
        buffer = Data(capacity: bufferSize)
    }
    
    init(_ path: String) {
        inputStream = InputStream(fileAtPath: path)
        inputStream?.open()
        buffer = Data(capacity: bufferSize)
    }
    
    func readData(maxLength length: Int) throws -> Data? {
        var buffer = [UInt8](repeating: 0, count: length)
        guard let result = inputStream?.read(&buffer, maxLength: buffer.count) else { return nil}
        if result < 0 {
            throw POSIXError(.EIO)
        } else {
            return Data(buffer.prefix(result))
        }
    }
    
    func readLine() -> String? {
        var rangeOfDelimiter = buffer.range(of: delimiter)
        
        while rangeOfDelimiter == nil {
            do {
                guard let chunk = try readData(maxLength: bufferSize) else { return nil }
                if chunk.count == 0 {
                    if buffer.count > 0 {
                        defer { buffer.count = 0 }
                        return String(data: buffer, encoding: .utf8)
                    }
                } else {
                    buffer.append(chunk)
                    rangeOfDelimiter = buffer.range(of: delimiter)
                }
                
            } catch let error {
                print("PSInputStreamReader readline error: \(error.localizedDescription)")
            }
           
        }
        
        let rangeOfLine = 0 ..< rangeOfDelimiter!.upperBound
        let line = String(data: buffer.subdata(in: rangeOfLine), encoding: .utf8)
        
        buffer.removeSubrange(rangeOfLine)
        
        return line?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func close() -> Void {
        inputStream?.close()
        inputStream = nil
    }
    
}

