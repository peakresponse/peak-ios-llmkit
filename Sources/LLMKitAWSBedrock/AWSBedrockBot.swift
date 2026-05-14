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

        let result = Task {
            do {
                let response = try await client.converse(input: converseInput)
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
            } catch (let error) {
                throw error
            }
        }
        let output = try await result.value
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
