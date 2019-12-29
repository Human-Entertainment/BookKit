//
//  Document.swift
//  Read
//
//  Created by Bastian Inuk Christensen on 24/02/2019.
//  Copyright © 2019 Bastian Inuk Christensen. All rights reserved.
//

/// Costum Document class for use for handling files 
public class Document {
    let data: Data
    let fileURL: URL
    init(fileURL: URL) throws {
        self.fileURL = fileURL
        do {
            data = Data.init(contentsOf: URL)
        } catch {
            throw
        }
    }
}
