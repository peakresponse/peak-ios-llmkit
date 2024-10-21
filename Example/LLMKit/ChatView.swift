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
    @State var input = ""

    init?(_ model: Model? = nil) {
        if let url = model?.downloadedURL, let template = model?.template {
            bot = Bot(from: url, template: template, maxTokenCount: 200)
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
