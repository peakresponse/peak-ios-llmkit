//
//  AWSBedrockRuntimeBot.swift
//  LLMKit
//
//  Created by Francis Li on 1/7/25.
//

@preconcurrency import AWSBedrockRuntime
@preconcurrency import AWSSDKIdentity
import Foundation
import LLMKit

open class AWSBedrockBot: Bot {
    @MainActor public static var region: String = "us-east-1"
    @MainActor public static var accessKeyId: String = ""
    @MainActor public static var secretAccessKey: String = ""
    @MainActor public static var sessionToken: String?
    
    @MainActor public static func configure(region: String, accessKeyId: String, secretAccessKey: String, sessionToken: String? = nil) {
        AWSBedrockBot.region = region
        AWSBedrockBot.accessKeyId = accessKeyId
        AWSBedrockBot.secretAccessKey = secretAccessKey
        AWSBedrockBot.sessionToken = sessionToken
    }
    
    @MainActor public static func register() {
        BotFactory.register(AWSBedrockBot.self, for: .awsBedrock)
    }
    
    private let client: BedrockRuntimeClient

    private var shouldContinuePredicting = false
    
    required public init?(model: Model) {
        let identityResolver = StaticAWSCredentialIdentityResolver(AWSCredentialIdentity(accessKey: AWSBedrockBot.accessKeyId,
                                                                                         secret: AWSBedrockBot.secretAccessKey,
                                                                                         sessionToken: AWSBedrockBot.sessionToken))
        if let config = try? BedrockRuntimeClient.BedrockRuntimeClientConfig(awsCredentialIdentityResolver: identityResolver,
                                                                             region: AWSBedrockBot.region) {
            client = BedrockRuntimeClient(config: config)
            super.init(model: model)
            return
        }
        return nil
    }

    @MainActor
    open func invoke(input: ConverseInput) async throws -> String {
        let response = try await client.converse(input: input)
        if let output = response.output {
            switch (output) {
            case .message(let message):
                if let content = message.content {
                    var output = ""
                    for block in content {
                        if case let .text(text) = block {
                            output += text
                        }
                    }
                    return output
                }
            case .sdkUnknown(let error):
                print(error)
            }
        }
        return ""
    }
    
    open override func invoke(promptId: String, with variables: [String : Any]) async throws -> BotResponse {
        var promptVariables: [String: BedrockRuntimeClientTypes.PromptVariableValues] = [:]
        for (key, value) in variables {
            promptVariables[key] = .text(String(describing: value))
        }
        let converseInput = ConverseInput(
            modelId: promptId,
            promptVariables: promptVariables
        )
        let output = try await invoke(input: converseInput)
        return BotResponse(text: output)
    }

    open override func respond(to input: String) async throws -> BotResponse {
        history.append((.user, input))
        let messages: [BedrockRuntimeClientTypes.Message] = [
            .init(content: [.text(input)],
                  role: .user)
        ]
        var system: [BedrockRuntimeClientTypes.SystemContentBlock]? = nil
        if let systemPrompt = model.template.systemPrompt {
            system = [
                .text(systemPrompt)
            ]
        }
        let converseInput = ConverseInput(
            messages: messages,
            modelId: model.id,
            system: system
        )
        let output = try await invoke(input: converseInput)
        history.append((.bot, output))
        return BotResponse(text: output)
    }
    
    open override func interrupt() {
        shouldContinuePredicting = false
    }
    
    open override func reset() {
        interrupt()
        history = []
    }
}

