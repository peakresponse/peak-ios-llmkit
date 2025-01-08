//
//  Bot.swift
//  LLMKit
//
//  Created by Francis Li on 1/7/25.
//

import Foundation

open class Bot: ObservableObject {
    @Published open var output = ""
    
    let model: Model
    
    @MainActor required public init?(model: Model) {
        self.model = model
    }
    
    open func respond(to input: String) async { }
    
    open func stop() { }
}
