import Testing
@testable import LLMKit
@testable import LLMKitAWSBedrock
@testable import LLMKitLlama

@MainActor @Test func testBotForModel() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    LlamaBot.register()
    
    let model = Model(
        id: "Llama-3.2-1B-Instruct.Q4_K_M.gguf",
        name: "llama-3.2-1B-Instruct.Q4_K_M.gguf",
        template: .chatML("You are an expert medical secretary."),
        url: "https://huggingface.co/QuantFactory/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct.Q4_K_M.gguf?download=true")
    
    let bot = BotFactory.instantiate(for: model)
    #expect(type(of: bot!) == LlamaBot.self)
}

@MainActor @Test func testBotForAwsBedrockModel() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    AWSBedrockBot.register()
    
    let model = Model(
        type: .awsBedrock,
        id: "Llama-3.2-1B-Instruct.Q4_K_M.gguf",
        name: "llama-3.2-1B-Instruct.Q4_K_M.gguf",
        template: .chatML("You are an expert medical secretary."))
    
    let bot = BotFactory.instantiate(for: model)
    #expect(type(of: bot!) == AWSBedrockBot.self)
}
