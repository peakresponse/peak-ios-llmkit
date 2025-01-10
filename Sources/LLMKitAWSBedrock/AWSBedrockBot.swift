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
    
    @MainActor public static func configure(region: String, accessKeyId: String, secretAccessKey: String) {
        AWSBedrockBot.region = region
        AWSBedrockBot.accessKeyId = accessKeyId
        AWSBedrockBot.secretAccessKey = secretAccessKey
    }
    
    @MainActor public static func register() {
        BotFactory.register(AWSBedrockBot.self, for: .awsBedrock)
    }
    
    private let client: BedrockRuntimeClient
    
    required public init?(model: Model) {
        if let identityResolver = try? StaticAWSCredentialIdentityResolver(AWSCredentialIdentity(accessKey: AWSBedrockBot.accessKeyId, secret: AWSBedrockBot.secretAccessKey)),
           let config = try? BedrockRuntimeClient.BedrockRuntimeClientConfiguration(awsCredentialIdentityResolver: identityResolver, region: AWSBedrockBot.region) {
            client = BedrockRuntimeClient(config: config)
            super.init(model: model)
            return
        }
        return nil
    }
    
    open override func respond(to input: String) async {
        let prompt = model.template.preprocess(input, [])
        let data: [String: String] = ["prompt": prompt]
        if let json = try? JSONEncoder().encode(data) {
            let params = InvokeModelInput(body: json, modelId: model.id)
            do {
                let response = await try client.invokeModel(input: params)
                if let body = response.body {
                    if let output = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
                        await setOutput(to: output["generation"] as? String ?? "")
                    }
                }
            } catch (let error) {
                print(error)
            }
        }
    }
}
