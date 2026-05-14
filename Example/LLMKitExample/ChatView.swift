//
//  ChatView.swift
//  LLMKitExample
//
//  Created by Francis Li on 10/15/24.
//

import LLMKit
import SwiftUI

func formatChatHistory(_ history: [ChatRecord]) -> String {
    var output = ""
    for chat in history {
        output += "\(chat.role): \(chat.content)\n\n"
    }
    return output
}

struct ChatView: View {
    let model: Model
    @ObservedObject var bot: Bot
    @State var input = ""

    init?(_ model: Model? = nil) {
        if let model, let bot = BotFactory.instantiate(for: model) {
            self.model = model
            self.bot = bot
            return
        }
        return nil
    }

    func respond() {
        Task {
            do {
                let output = try await bot.respond(to: input)
                print(output, output.asJSON() as Any)
                input = ""
            } catch (let error) {
                print(error)
            }
        }
    }
        
    func stop() {
        if input == "" {
            bot.reset()
        } else {
            bot.interrupt()
            input = ""
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView { Text(formatChatHistory(bot.history)).monospaced() }
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
