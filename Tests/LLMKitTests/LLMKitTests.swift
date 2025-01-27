import Testing
@testable import LLMKit
@testable import LLMKitAWSBedrock
@testable import LLMKitLlama

@Test func testLlama3Template() async throws {
    let template = PromptTemplate.llama3("You are an expert medical secretary.")
    let prompt = template.preprocess("This is a test", [])
    #expect(prompt == "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n" +
                      "You are an expert medical secretary.<|eot_id|><|start_header_id|>user<|end_header_id|>\n\n" +
                      "This is a test<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n")
}

@MainActor @Test func testBotForAwsBedrockModel() async throws {
    AWSBedrockBot.register()
    AWSBedrockBot.configure(region: "us-east-1", accessKeyId: "test", secretAccessKey: "test")
    
    let model = Model(
        type: .awsBedrock,
        id: "us.meta.llama3-3-70b-instruct-v1:0",
        name: "AWS Bedrock US Meta Llama 3.3 70B Instruct",
        template: .llama3("You are an expert medical secretary."))
    
    let bot = BotFactory.instantiate(for: model)
    #expect(type(of: bot!) == AWSBedrockBot.self)
}
