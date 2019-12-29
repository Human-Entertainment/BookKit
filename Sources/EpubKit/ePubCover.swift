//
//  File.swift
//  
//
//  Created by Bastian Inuk Christensen on 06/12/2019.
//

//import BookKit
#if os(iOS)
import UIKit

public typealias Image = UIImage
#elseif os(macOS)
import AppKit

public typealias Image = NSImage
#endif
// MARK: - Cover extractor
extension ePub {
    /// Returns the cover image of a given book as `UIImage`
    public func extractCover(frame: CGRect) throws -> Image {
       // return try unpackEpub{ workDir -> UIImage in
            var coverName = ""
            
            if let items = self.meta?.meta {
                for item in items {
                    if item.name == "cover" {
                        coverName = item.content!
                    }
                }
            }
            
            if let items = self.manifest?.item {
                for item in items {
                    if item.name == coverName {
                        var coverURL = uncompressedBookURL
                        coverURL.appendPathComponent(self.OEPBS)
                        coverURL.appendPathComponent(item.link)
                        let coverData = try Data(contentsOf: coverURL)
                        let cover = Image(data: coverData)!
                        return cover
                    }
                }
            }
            
            throw XMLError.coverNotFound
        //}
        
    }
}
