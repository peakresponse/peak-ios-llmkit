//
//  BotFactory.swift
//  LLMKit
//
//  Created by Francis Li on 1/8/25.
//

import Foundation

@MainActor
public class BotFactory {
    private static var registry: [ModelType: Bot.Type] = [:]
    
    public static func register(_ bot: Bot.Type, for type: ModelType) {
        BotFactory.registry[type] = bot
    }
    
    public static func instantiate(for model: Model) -> Bot? {
        return BotFactory.registry[model.type]?.init(model: model)
    }
}
