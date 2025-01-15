//
//  AWSBedrockRuntimeBot.swift
//  LLMKit
//
//  Created by Francis Li on 1/7/25.
//

import AWSBedrockRuntime
import AWSSDKIdentity
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
        if let identityResolver = try? StaticAWSCredentialIdentityResolver(AWSCredentialIdentity(accessKey: AWSBedrockBot.accessKeyId, secret: AWSBedrockBot.secretAccessKey, sessionToken: AWSBedrockBot.sessionToken)),
           let config = try? BedrockRuntimeClient.BedrockRuntimeClientConfiguration(awsCredentialIdentityResolver: identityResolver, region: AWSBedrockBot.region) {
            client = BedrockRuntimeClient(config: config)
            super.init(model: model)
            return
        }
        return nil
    }
    
    open override func respond(to input: String, isStreaming: Bool = true) async throws -> String {
        var output = ""
        let history = self.history
        let prompt = model.template.preprocess(input, history)
        let data: [String: String] = ["prompt": prompt]
        let json = try JSONEncoder().encode(data)
        if isStreaming {
            let params = InvokeModelWithResponseStreamInput(body: json, modelId: model.id)
            shouldContinuePredicting = true
            await Task {
                do {
                    let response = try await client.invokeModelWithResponseStream(input: params)
                    if let body = response.body {
                        for try await stream in body {
                            if !shouldContinuePredicting {
                                break
                            }
                            switch stream {
                            case .chunk(let part):
                                if let bytes = part.bytes,
                                   let data = try? JSONSerialization.jsonObject(with: bytes) as? [String: Any],
                                   let generation = data["generation"] as? String {
                                    output += generation
                                    self.history = history + [(.user, input), (.bot, output)]
                                }
                            case .sdkUnknown(let message):
                                print("sdkUnknown", message)
                                break
                            }
                        }
                    }
                } catch (let error) {
                    throw error
                }
            }
            return output
        }
        // non-streaming
        let params = InvokeModelInput(body: json, modelId: model.id)
        await Task {
            do {
                let response = try await client.invokeModel(input: params)
                if let body = response.body {
                    if let data = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any],
                       let generation = data["generation"] as? String {
                        output = generation
                        self.history = history + [(.user, input), (.bot, output)]
                    }
                }
            } catch (let error) {
                throw error
            }
        }
        return output
    }
    
    open override func interrupt() {
        shouldContinuePredicting = false
    }
    
    open override func reset() {
        interrupt()
        history = []
    }
}
