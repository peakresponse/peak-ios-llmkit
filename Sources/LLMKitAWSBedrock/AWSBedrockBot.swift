//
//  AWSBedrockRuntimeBot.swift
//  LLMKit
//
//  Created by Francis Li on 1/7/25.
//

import LLMKit

open class AWSBedrockBot: Bot {
    @MainActor public static func register() {
        BotFactory.register(AWSBedrockBot.self, for: .awsBedrock)
    }
}
