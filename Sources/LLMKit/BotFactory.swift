//
//  BotFactory.swift
//  LLMKit
//
//  Created by Francis Li on 1/8/25.
//

import Foundation

public class BotFactory {
    @MainActor private static var bots: [ModelType: Bot.Type] = [:]
    
    @MainActor public static func register(_ bot: Bot.Type, for type: ModelType) {
        BotFactory.bots[type] = bot
    }
    
    @MainActor public static func instantiate(for model: Model) -> Bot? {
        return BotFactory.bots[model.type]?.init(model: model)
    }
}
