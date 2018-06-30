//
//  EPUBContentService.swift
//  EPUBKit
//
//  Created by Witek Bobrowski on 30/06/2018.
//  Copyright © 2018 Witek Bobrowski. All rights reserved.
//

import Foundation
import AEXML

protocol EPUBContentService {
    var contentDirectory: URL { get }
    var spine: AEXMLElement { get }
    var metadata: AEXMLElement { get }
    var manifest: AEXMLElement { get }
    init(_ url: URL) throws
    func tableOfContents(_ fileName: String) throws -> AEXMLElement
}

class EPUBContentServiceImplementation: EPUBContentService {

    private var content: AEXMLDocument

    let contentDirectory: URL

    var spine: AEXMLElement {
        return content.root["spine"]
    }
    var metadata: AEXMLElement {
        return content.root["metadata"]
    }
    var manifest: AEXMLElement {
        return content.root["manifest"]
    }

    required init(_ url: URL) throws {
        let path = try EPUBContentServiceImplementation.getContentPath(from: url)
        contentDirectory = path.deletingLastPathComponent()
        let data = try Data(contentsOf: path)
        content = try AEXMLDocument(xml: data)
    }

    func tableOfContents(_ fileName: String) throws -> AEXMLElement {
        let path = contentDirectory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: path)
        return try AEXMLDocument(xml: data).root
    }

}

extension EPUBContentServiceImplementation {

    static private func getContentPath(from url: URL) throws -> URL {
        let path = url.appendingPathComponent("META-INF/container.xml")
        let data = try Data(contentsOf: path)
        let container = try AEXMLDocument(xml: data)
        guard let content = container.root["rootfiles"]["rootfile"].attributes["full-path"] else {
            throw EPUBParserError.containerParseError
        }
        return url.appendingPathComponent(content)
    }

}
