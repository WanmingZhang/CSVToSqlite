//
//  PSCSVParser.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/23/23.
//

import Foundation

// helper function to parse CSV files

// TODO: update deprecated API
struct PSCSVParser {
    func parseCSV(contentsOfURL: NSURL, encoding: String.Encoding, completion: @escaping (Result<[PSProduct]?, Error>) -> Void) {
        let delimiter = ","
        var items = [PSProduct(productId: "", title: "", listPrice: 0, salesPrice: 0, color: "", size: "")]
        // Load the CSV file and parse it
        do {
            let content = try String(contentsOf: contentsOfURL as URL, encoding: encoding)
            items = []
            let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
            for line in lines {
                var values:[String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.range(of: "\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:Scanner = Scanner(string: textToScan)
                        while textScanner.string != "" {
                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpTo("\"", into: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpTo(delimiter, into: &value)
                            }
                            // Store the value into the values array
                            values.append(value! as String)

                            // Retrieve the unscanned remainder of the string
                            if textScanner.scanLocation < textScanner.string.count {
                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)
                        }
                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    } else  {
                        values = line.components(separatedBy: delimiter)
                    }
                    // Put the values into the tuple and add it to the items array
                    let item = PSProduct(productId: values[0], title: values[1], listPrice: Double(values[2]) ?? 0, salesPrice: Double(values[3]) ?? 0, color: values[4], size: values[5])
                    items.append(item)
                }
            }
            completion(.success(items))
            return
        } catch let error {
            completion(.failure(error))
            return
        }
    }
}
