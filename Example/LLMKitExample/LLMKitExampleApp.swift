//
//  LLMKitExampleApp.swift
//  LLMKitExample
//
//  Created by Francis Li on 1/7/25.
//

import SwiftUI

@main
struct LLMKitExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ModelsView()
        }
    }
}
