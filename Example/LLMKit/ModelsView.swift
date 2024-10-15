//
//  ModelsView.swift
//  LLMKit_Example
//
//  Created by Francis Li on 10/13/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import LLMKit
import SwiftUI

@Observable
class Model: Identifiable {
    let id: String
    let name: String
    let url: String
    var isDownloaded: Bool
    var isDownloading: Bool
    var downloadedURL: URL?

    init(id: String, name: String, url: String, isDownloaded: Bool, isDownloading: Bool) {
        self.id = id
        self.name = name
        self.url = url
        self.isDownloaded = isDownloaded
        self.isDownloading = isDownloading
    }
}

struct ModelView: View {
    @Bindable var model: Model
    var body: some View {
        HStack {
            if model.isDownloaded {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 28)
            } else if model.isDownloading {
                ProgressView()
                    .frame(width: 28)
                
            } else {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 28)
            }
            Text(model.name)
        }
    }
}

struct ModelsView: View {
    @State var models: [Model] = []
    @State var downloadedModels: [Model] = []

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Downloaded")) {
                    ForEach(downloadedModels) { model in
                        NavigationLink(destination: ChatView(model)) {
                            ModelView(model: model)
                        }
                    }
                    if downloadedModels.count == 0 {
                        Text("No models downloaded.")
                    }
                }
                Section(header: Text("Models")) {
                    ForEach(models) { model in
                        ModelView(model: model).onTapGesture {
                            if !model.isDownloading {
                                if let url = URL(string: model.url) {
                                    Task {
                                        await ModelManager.shared.download(url)
                                    }
                                }
                                model.isDownloading.toggle()
                                print("Downloading", model.isDownloading)
                            }
                        }
                    }
                    if models.count == 0 {
                        Text("No models to download.")
                    }
                }
            }
            .navigationTitle("Models")
            .task {
                var models = [
                    Model(
                        id: "openhermes-2.5-mistral-7b.Q4_K_M.gguf",
                        name: "openhermes-2.5-mistral-7b.Q4_K_M.gguf",
                        url: "https://huggingface.co/TheBloke/OpenHermes-2.5-Mistral-7B-GGUF/resolve/main/openhermes-2.5-mistral-7b.Q4_K_M.gguf?download=true",
                        isDownloaded: false,
                        isDownloading: false)
                ]
                var downloadedModels: [Model] = []
                if let downloaded = try? ModelManager.shared.list() {
                    for url in downloaded {
                        let id = url.lastPathComponent
                        if let model = models.first(where: { $0.id == id }) {
                            model.isDownloaded.toggle()
                            model.downloadedURL = url
                            downloadedModels.append(model)
                            models.removeAll(where: { $0.id == id })
                        }
                    }
                }
                downloadedModels.sort(by: { $0.name > $1.name })
                self.downloadedModels.removeAll()
                self.downloadedModels.append(contentsOf: downloadedModels)

                let tasks = await ModelManager.shared.allDownloads
                for task in tasks {
                    if let url = task.originalRequest?.url?.absoluteString,
                       let model = models.first(where: { $0.url == url }) {
                        model.isDownloading.toggle()
                        print(task.countOfBytesExpectedToReceive, task.countOfBytesReceived)
                    }
                }
                models.sort(by: { $0.name > $1.name })
                self.models.removeAll()
                self.models.append(contentsOf: models)
            }
        }
    }
}

#Preview {
    ModelsView()
}
