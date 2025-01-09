//
//  Model.swift
//  
//
//  Created by Francis Li on 1/7/25.
//

import LLM
import SwiftUI

extension Template {
    public static func llama3(_ systemPrompt: String? = nil) -> Template {
        return Template(
            prefix: "<|begin_of_text|>",
            system: ("<|start_header_id|>system<|end_header_id|>", "<|eot_id|>"),
            user: ("<|start_header_id|>user<|end_header_id|>", "<|eot_id|>"),
            bot: ("<|start_header_id|>assistant<|end_header_id|>", "<|eot_id|>"),
            stopSequence: "<|end_of_text|>",
            systemPrompt: systemPrompt
        )
    }
}

public typealias PromptTemplate = Template

public enum ModelType: String, Codable {
    case gguf
    case awsBedrock
}

@Observable
open class Model: Identifiable {
    public let type: ModelType
    public let id: String
    public let name: String
    public let template: PromptTemplate
    public var maxTokenCount: Int32 = 1000
    public let url: String
    public var isDownloaded: Bool
    public var isDownloading: Bool
    public var downloadedURL: URL?
    public var bytesDownloaded: Int64 = 0
    public var bytesExpected: Int64 = 0

    public init(type: ModelType = .gguf, id: String, name: String, template: PromptTemplate, maxTokenCount: Int32 = 1000, url: String = "", isDownloaded: Bool = false, isDownloading: Bool = false) {
        self.type = type
        self.id = id
        self.name = name
        self.url = url
        self.template = template
        self.isDownloaded = isDownloaded
        self.isDownloading = isDownloading
    }
}
