//
//  MarkdownDocument.swift
//  7III Recipes
//
//  Created by Simon Lang on 11.02.2024.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var markdown: UTType {
        UTType(importedAs: "public.plainText")
    }
}



struct MarkdownFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.markdown] }

    var content: String

    init(content: String = "") {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let decodedString = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.content = decodedString
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }

}
