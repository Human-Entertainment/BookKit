//
//  ePub.swift
//  Read
//
//  Created by Bastian Inuk Christensen on 25/02/2019.
//  Copyright © 2019 Bastian Inuk Christensen. All rights reserved.
//
import Foundation
import ZIPFoundation
import XMLCoder
import BookKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
// MARK: - Book metadata
/// ePub handler class
public class ePub {
    private let fileManager: FileManager
    private let workDir: URL
    private let compressedBook: Document
    private let bookFolder: String
    private var coverLink: String?
    /// ePub metadata, use this to get information
    public private(set) var meta: EpubMeta? = nil
    public private(set) var manifest: Manifest? = nil
    public private(set) var pages: [String]
    private var spine: Spine? = nil
    public private(set) var OEPBS: String = ""
    
    private var needsCleanup: Bool
    public private(set) var uncompressedBookURL: URL
    
    public init(_ compressedBook: Document) throws {
        self.fileManager = FileManager()
        self.compressedBook = compressedBook
        self.workDir = fileManager.temporaryDirectory
        self.bookFolder = URL(fileURLWithPath: compressedBook.fileURL.path).deletingPathExtension().lastPathComponent
        self.pages = [String]()
        self.needsCleanup = false
        self.uncompressedBookURL = URL(fileURLWithPath: compressedBook.fileURL.path)
        unpackEpub()
        try doXML()
        guard let spine = self.spine else {
            throw XMLError.NotEpub
        }
        guard let manifest = self.manifest else {
            throw XMLError.NotEpub
        }
        self.pages = manifest.item.filter { item in
            return spine.itemref.contains {$0.idref == item.name}
        }.map { $0.link }
            
            /*spine.itemref.compactMap { page in
            if (self.manifest?.item.contains { $0.name == page.idref } ?? false) {
                // this should be the link
                return page.idref
            } else {
                return nil
            }
        }*/
        /*
        for page in self.spine!.itemref {
            for item in self.manifest!.item{
                if page.idref == item.name {
                    pages.append(item.link)
                }
            }
        }*/
    }
    
    deinit {
        if (needsCleanup) {
            try? fileManager.removeItem(at: uncompressedBookURL)
        }
    }
}

// MARK: - New ePub XML Parser
extension ePub {
    
    private func doXML() throws -> Void {
        
        var rootfileXML = container()
        let decoder = XMLDecoder()
            decoder.shouldProcessNamespaces = true
        do {
            let xmlData = try Data(contentsOf: uncompressedBookURL.appendingPathComponent("META-INF/container.xml"))
            rootfileXML = try decoder.decode(container.self, from: xmlData)
            var oepbsURL: URL = URL(fileURLWithPath: (rootfileXML.rootfiles?.rootfile?.path)!)
            oepbsURL.deleteLastPathComponent()
            
            self.OEPBS = oepbsURL.lastPathComponent
            
        } catch {
            throw XMLError.NotEpub
        }
        
        do {
            let xmlData = try Data(contentsOf: uncompressedBookURL.appendingPathComponent((rootfileXML.rootfiles?.rootfile?.path!)!))
            #if DEBUG
            let xmlString = String(data: xmlData, encoding: .utf8)
            #endif
            var packageXML = package()
            packageXML = try decoder.decode(package.self, from: xmlData)
            self.meta = packageXML.metadata
            self.manifest = packageXML.manifest
            self.spine = packageXML.spine
        } catch {
            print(error)
            throw XMLError.ParseError
        }
    }
}
// MARK: - ePub unzipper
extension ePub {
    
    /// Unpack the epub, get specified xml file, container.xml if no `relativePath` has been passed in, parse xml file, and delete the unpacked epub file afterwards
    private func unpackEpub(_ relativePath: String? = nil){
        
        let compressedBookURL = self.compressedBook.fileURL
        var uncompressedBookURL: URL = compressedBookURL
        if (!fileManager.fileExists(atPath: compressedBookURL.appendingPathComponent("META-INF").appendingPathComponent("container.xml").path)){
            
            uncompressedBookURL = workDir.appendingPathComponent(bookFolder)
            uncompressedBookURL.appendPathExtension("zip")
            
            if !fileManager.fileExists(atPath: uncompressedBookURL.path){
                try! fileManager.copyItem(atPath: compressedBookURL.path, toPath: uncompressedBookURL.path)
            }
            uncompressedBookURL = unzip(uncompressedBookURL)
            
            needsCleanup = true
            self.uncompressedBookURL = uncompressedBookURL
        }
    }

    private func unzip(_ archive: URL) -> URL {
        var destinationURL = workDir
        destinationURL = destinationURL.appendingPathComponent(self.bookFolder)
        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: archive, to: destinationURL)
            try fileManager.removeItem(at: archive)
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
        
        return destinationURL
    }
}

fileprivate struct container: Codable {
    var rootfiles: rootfiles?
    enum CodingKeys: String, CodingKey {
        case rootfiles = "rootfiles"
    }
}

fileprivate struct rootfiles: Codable {
    var rootfile: rootfile?
    enum CodingKeys: String, CodingKey {
        case rootfile = "rootfile"
    }
}

fileprivate struct rootfile: Codable {
    var path: String?
    var mediaType: String?
    enum CodingKeys: String, CodingKey {
        case path = "full-path"
        case mediaType = "media-type"
    }
}

struct package: Codable {
    public private(set) var metadata: EpubMeta?
    public private(set) var manifest: Manifest?
    public private(set) var spine: Spine?
}

// MARK: - EpubMetaData
public struct EpubMeta: Codable {
    public private(set) var title: String
    public private(set) var creator: [Creators]?
    public private(set) var meta: [Meta]
}

public struct Creators: Codable {
    let id: String?
    let value: String
}

public struct Meta: Codable {
    let name: String?
    let content: String?
}

public struct Manifest: Codable {
    var item: [Items]
}

struct Items: Codable {
    var name: String
    var mediatype: String
    var link: String
    enum CodingKeys: String, CodingKey {
        case name = "id"
        case mediatype = "media-type"
        case link = "href"
    }
}

// MARK: - Spine
struct Spine: Codable {
    var itemref: [itemref]
}

struct itemref: Codable {
    var idref: String
}

// MARK: - Custom errors
enum XMLError: String, Error {
    case FileExists
    case SomethingWentWrong = "Something unown went wrong"
    case coverNotFound = "Cover not found"
    case NotEpub = "The given fils is not a valid epub file"
    case ParseError = "Error parsing the ePub file"
}
