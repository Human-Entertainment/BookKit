//
//  Document.swift
//  Read
//
//  Created by Bastian Inuk Christensen on 24/02/2019.
//  Copyright © 2019 Bastian Inuk Christensen. All rights reserved.
//
import Foundation


/// Costum Document class for use for handling files
public class Document {
    public let data: Data?
    public let fileURL: URL
    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.data = try? Data(contentsOf: fileURL)
    }
    
    public func open(completionHandler: (Bool) -> (Void)?){
        completionHandler(data != nil ? true : false)
    }
}

enum DocumentError: Error {
    case FileNotFound
}
