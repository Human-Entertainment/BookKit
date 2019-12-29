//
//  Document.swift
//  Read
//
//  Created by Bastian Inuk Christensen on 24/02/2019.
//  Copyright © 2019 Bastian Inuk Christensen. All rights reserved.
//
#if os(iOS)
import UIKit

public typealias SysDocument = UIDocument
#elseif os(macOS)
import AppKit

public typealias SysDocument = NSDocument
#endif

/// Convenience class for The two os' native Document type
public class Document : SysDocument {
    #if os(iOS)
    override public func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override public func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
    #endif
}
