//
//  LlamaBot.swift
//  llmkit
//
//  Created by Francis Li on 1/7/25.
//


import Combine
import LLM
import LLMKit

open class LlamaBot: Bot {
    @MainActor public static func register() {
        BotFactory.register(LlamaBot.self, for: .gguf)
    }

    private var llm: LLM
    private var subscription: AnyCancellable?
    
    required public init?(model: LLMKit.Model) {
        if let downloadedURL = model.downloadedURL {
            llm = LLM(from: downloadedURL, template: model.template, maxTokenCount: model.maxTokenCount)
            super.init(model: model)
            self.subscription = llm.objectWillChange.sink { [weak self] in
                print("!!!", self?.llm.output)
                self?.output = self?.llm.output ?? ""
            }
            return
        }
        return nil
    }
    
    deinit {
        self.subscription = nil
    }
    
    override public func respond(to input: String) async {
        await llm.respond(to: input)
    }

    override public func stop() {
        llm.stop()
    }
}
