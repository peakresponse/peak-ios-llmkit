//
//  PromptTemplate.swift
//  LLMKit
//
//  Created by Francis Li on 4/15/25.
//

public struct PromptTemplate: Sendable {
    public typealias Attachment = (prefix: String, suffix: String)
    public let system: Attachment
    public let user: Attachment
    public let bot: Attachment
    public let systemPrompt: String?
    public let stopSequence: String?
    public let prefix: String
    public let shouldDropLast: Bool
    
    public init(
        prefix: String = "",
        system: Attachment? = nil,
        user: Attachment? = nil,
        bot: Attachment? = nil,
        stopSequence: String? = nil,
        systemPrompt: String?,
        shouldDropLast: Bool = false
    ) {
        self.system = system ?? ("", "")
        self.user = user  ?? ("", "")
        self.bot = bot ?? ("", "")
        self.stopSequence = stopSequence
        self.systemPrompt = systemPrompt
        self.prefix = prefix
        self.shouldDropLast = shouldDropLast
    }
    
    public var preprocess: @Sendable (_ input: String, _ history: [ChatRecord]) -> String {
        return { [self] input, history in
            var processed = prefix
            if let systemPrompt {
                processed += "\(system.prefix)\(systemPrompt)\(system.suffix)"
            }
            for chat in history {
                if chat.role == .user {
                    processed += "\(user.prefix)\(chat.content)\(user.suffix)"
                } else {
                    processed += "\(bot.prefix)\(chat.content)\(bot.suffix)"
                }
            }
            processed += "\(user.prefix)\(input)\(user.suffix)"
            if shouldDropLast {
                processed += bot.prefix.dropLast()
            } else {
                processed += bot.prefix
            }
            return processed
        }
    }
    
    public static func chatML(_ systemPrompt: String? = nil) -> PromptTemplate {
        return PromptTemplate(
            system: ("<|im_start|>system\n", "<|im_end|>\n"),
            user: ("<|im_start|>user\n", "<|im_end|>\n"),
            bot: ("<|im_start|>assistant\n", "<|im_end|>\n"),
            stopSequence: "<|im_end|>",
            systemPrompt: systemPrompt
        )
    }
    
    public static func alpaca(_ systemPrompt: String? = nil) -> PromptTemplate {
        return PromptTemplate(
            system: ("", "\n\n"),
            user: ("### Instruction:\n", "\n\n"),
            bot: ("### Response:\n", "\n\n"),
            stopSequence: "###",
            systemPrompt: systemPrompt
        )
    }
    
    public static func llama(_ systemPrompt: String? = nil) -> PromptTemplate {
        return PromptTemplate(
            prefix: "[INST] ",
            system: ("<<SYS>>\n", "\n<</SYS>>\n\n"),
            user: ("", " [/INST]"),
            bot: (" ", "</s><s>[INST] "),
            stopSequence: "</s>",
            systemPrompt: systemPrompt,
            shouldDropLast: true
        )
    }
    
    public static let mistral = PromptTemplate(
        user: ("[INST] ", " [/INST]"),
        bot: ("", "</s> "),
        stopSequence: "</s>",
        systemPrompt: nil
    )

    public static let gemma = PromptTemplate(
        user: ("<start_of_turn>user\n", "<end_of_turn>\n"),
        bot: ("<start_of_turn>model\n", "<end_of_turn>\n"),
        stopSequence: "<end_of_turn>",
        systemPrompt: nil
    )

    public static func llama3(_ systemPrompt: String? = nil) -> PromptTemplate {
        return PromptTemplate(
            prefix: "<|begin_of_text|>",
            system: ("<|start_header_id|>system<|end_header_id|>\n\n", "<|eot_id|>"),
            user: ("<|start_header_id|>user<|end_header_id|>\n\n", "<|eot_id|>"),
            bot: ("<|start_header_id|>assistant<|end_header_id|>\n\n", "<|eot_id|>"),
            stopSequence: "<|end_of_text|>",
            systemPrompt: systemPrompt
        )
    }
    
    func withSystemPrompt(_ systemPrompt: String?) -> PromptTemplate {
        return PromptTemplate(prefix: prefix, system: system, user: user, bot: bot, stopSequence: stopSequence, systemPrompt: systemPrompt)
    }
}
