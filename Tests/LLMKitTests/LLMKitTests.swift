import Testing
@testable import LLMKit
@testable import LLMKitAWSBedrock

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
