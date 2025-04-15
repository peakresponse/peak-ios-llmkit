//
//  Bot.swift
//  LLMKit
//
//  Created by Francis Li on 1/7/25.
//

import Foundation

public enum Role {
    case user
    case bot
}

public typealias ChatRecord = (role: Role, content: String)

public struct BotResponse {
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public func asJSON() -> [String: Any]? {
        var input = text
        if input.hasPrefix("```"), input.hasSuffix("```") {
            input = String(input[input.index(input.startIndex, offsetBy: 3)...input.index(input.endIndex, offsetBy: -4)])
            if input.hasPrefix("json") {
                input = String(input[input.index(input.startIndex, offsetBy: 4)...])
            }
        }
        if let data = input.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        }
        return nil
    }
}

open class Bot: ObservableObject {
    @Published public var history: [ChatRecord] = []

    public let model: Model
    
    @MainActor required public init?(model: Model) {
        self.model = model
    }
    
    @MainActor open func respond(to input: String, isStreaming: Bool = true) async throws -> BotResponse {
        return BotResponse(text: "")
    }

    @MainActor open func interrupt() { }

    @MainActor open func reset() { }
}
