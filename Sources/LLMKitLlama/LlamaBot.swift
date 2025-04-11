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
        if let downloadedURL = model.downloadedURL, let llm = LLM(from: downloadedURL, template: model.template, maxTokenCount: model.maxTokenCount) {
            self.llm = llm
            super.init(model: model)
            subscription = llm.objectWillChange.sink { [weak self] in
                guard let self = self else { return }
                self.objectWillChange.send()
                if var chat = self.history.last {
                    if self.history.count > 3 {
                        let prevChat = self.history[self.history.count - 3]
                        if prevChat.content == self.llm.output {
                            return
                        }
                    }
                    chat.content = self.llm.output
                    self.history[history.endIndex - 1] = chat
                }
            }
            return
        }
        return nil
    }
    
    deinit {
        subscription = nil
    }
    
    override open func respond(to input: String, isStreaming: Bool = true) async throws -> BotResponse {
        history += [(.user, input), (.bot, "")]
        let result = Task {
            await llm.respond(to: input)
            if var chat = history.last {
                chat.content = llm.output
                history[history.endIndex - 1] = chat
            }
            return llm.output
        }
        return BotResponse(text: await result.value)
    }

    override open func interrupt() {
        llm.stop()
    }
    
    override open func reset() {
        llm.stop()
        llm.history = []
        history = []
    }
}
