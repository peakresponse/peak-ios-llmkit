//
//  Bot.swift
//  LLMKit
//
//  Created by Francis Li on 1/7/25.
//

import Foundation
import LLM

public typealias ChatHistory = Chat

open class Bot: ObservableObject {
    @Published public var history: [ChatHistory] = []

    public let model: Model
    
    @MainActor required public init?(model: Model) {
        self.model = model
    }
    
    @MainActor open func respond(to input: String, isStreaming: Bool = true) async throws -> String {
        return ""
    }

    @MainActor open func interrupt() { }

    @MainActor open func reset() { }
}
