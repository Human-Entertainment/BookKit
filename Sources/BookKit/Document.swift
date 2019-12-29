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
    public let data: Data
    public let fileURL: URL
    init(fileURL: URL) throws {
        self.fileURL = fileURL
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw DocumentError.FileNotFound
        }
    }
}

enum DocumentError: Error {
    case FileNotFound
}
