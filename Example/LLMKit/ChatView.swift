//
//  ChatView.swift
//  LLMKit_Example
//
//  Created by Francis Li on 10/15/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import LLM
import SwiftUI

class Bot: LLM {
    
}

struct ChatView: View {
    @ObservedObject var bot: Bot
    @State var input = "Give me seven national flag emojis people use the most; You must include South Korea."

    init?(_ model: Model? = nil) {
        if let url = model?.downloadedURL {
            let systemPrompt = "You are a sentient AI with emotions."
            bot = Bot(from: url, template: .chatML(systemPrompt))
            return
        }
        return nil
    }

    func respond() { 
        Task {
            await bot.respond(to: input)
        }
    }
        
    func stop() { 
        bot.stop()
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView { Text(bot.output).monospaced() }
            Spacer()
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).foregroundStyle(.thinMaterial).frame(height: 40)
                    TextField("input", text: $input).padding(8)
                }
                Button(action: respond) { Image(systemName: "paperplane.fill") }
                Button(action: stop) { Image(systemName: "xmark") }
            }
        }.frame(maxWidth: .infinity).padding()
    }
}

#Preview {
    ChatView()
}
