//
//  Model.swift
//  
//
//  Created by Francis Li on 1/7/25.
//

import LLM
import SwiftUI

@Observable
open class ModelMetadata: Identifiable {
    public let id: String
    public let name: String
    public let url: String
    public let template: Template
    public var isDownloaded: Bool
    public var isDownloading: Bool
    public var downloadedURL: URL?
    public var bytesDownloaded: Int64 = 0
    public var bytesExpected: Int64 = 0

    public init(id: String, name: String, url: String, template: Template, isDownloaded: Bool, isDownloading: Bool) {
        self.id = id
        self.name = name
        self.url = url
        self.template = template
        self.isDownloaded = isDownloaded
        self.isDownloading = isDownloading
    }
}
