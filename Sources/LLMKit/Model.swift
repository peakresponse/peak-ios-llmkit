//
//  Model.swift
//  
//
//  Created by Francis Li on 1/7/25.
//

import LLM
import SwiftUI

@Observable
open class Model: Identifiable {
    let id: String
    let name: String
    let url: String
    let template: Template
    var isDownloaded: Bool
    var isDownloading: Bool
    var downloadedURL: URL?
    var bytesDownloaded: Int64 = 0
    var bytesExpected: Int64 = 0

    init(id: String, name: String, url: String, template: Template, isDownloaded: Bool, isDownloading: Bool) {
        self.id = id
        self.name = name
        self.url = url
        self.template = template
        self.isDownloaded = isDownloaded
        self.isDownloading = isDownloading
    }
}
