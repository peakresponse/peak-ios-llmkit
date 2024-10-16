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
    var bytesDownloaded: Int64 = 0
    var bytesExpected: Int64 = 0

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
    @State var showDeleteConfirmation = false

    var body: some View {
        HStack {
            if model.isDownloaded {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 28)
                    .onTapGesture {
                        showDeleteConfirmation = true
                    }
            } else if model.isDownloading {
                ProgressView()
                    .frame(width: 28)
                
            } else {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 28)
            }
            VStack(alignment: .leading) {
                Text(model.name)
                if model.isDownloading {
                    Text("\(model.bytesDownloaded / (1024 * 1024))MB / \(model.bytesExpected / (1024 * 1024))MB")
                }
            }
        }.alert("Are you sure?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                do {
                    try ModelManager.shared.delete(model.id)
                    model.isDownloaded = false
                    model.isDownloading = false
                } catch { }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you wish to delete the model \(model.name)?")
        }
    }
}

@Observable
class ModelUpdates: NSObject, URLSessionDownloadDelegate {
    var models: [Model] = []

    override init() {
        super.init()
        ModelManager.shared.delegate = self
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let url = downloadTask.originalRequest?.url?.absoluteString {
            for model in models {
                if model.url == url {
                    model.isDownloaded = true
                    break
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let url = downloadTask.originalRequest?.url?.absoluteString {
            for model in models {
                if model.url == url {
                    model.bytesDownloaded = totalBytesWritten
                    model.bytesExpected = totalBytesExpectedToWrite
                    break
                }
            }
        }
    }
}

struct ModelsView: View {
    @State var updates = ModelUpdates()

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Models")) {
                    ForEach(updates.models) { model in
                        if model.isDownloaded {
                            NavigationLink(value: model.id) {
                                ModelView(model: model)
                            }
                        } else {
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
                    }
                    if updates.models.count == 0 {
                        Text("No models to download.")
                    }
                }
            }
            .navigationTitle("Models")
            .navigationDestination(for: String.self, destination: { id in
                let model = updates.models.first(where: { $0.id == id })
                ChatView(model)
            })
            .task {
                var models = [
                    Model(
                        id: "openhermes-2.5-mistral-7b.Q4_K_M.gguf",
                        name: "openhermes-2.5-mistral-7b.Q4_K_M.gguf",
                        url: "https://huggingface.co/TheBloke/OpenHermes-2.5-Mistral-7B-GGUF/resolve/main/openhermes-2.5-mistral-7b.Q4_K_M.gguf?download=true",
                        isDownloaded: false,
                        isDownloading: false),
                    Model(
                        id: "openbiollm-llama3-8b.Q4_K_M.gguf",
                        name: "openbiollm-llama3-8b.Q4_K_M.gguf",
                        url: "https://huggingface.co/aaditya/OpenBioLLM-Llama3-8B-GGUF/resolve/main/openbiollm-llama3-8b.Q4_K_M.gguf?download=true",
                        isDownloaded: false,
                        isDownloading: false),
                    Model(
                        id: "meditron-7b.Q4_K_M.gguf",
                        name: "meditron-7b.Q4_K_M.gguf",
                        url: "https://huggingface.co/TheBloke/meditron-7B-GGUF/resolve/main/meditron-7b.Q4_K_M.gguf?download=true",
                        isDownloaded: false,
                        isDownloading: false)
                ]
                if let downloaded = try? ModelManager.shared.list() {
                    for url in downloaded {
                        let id = url.lastPathComponent
                        if let model = models.first(where: { $0.id == id }) {
                            model.isDownloaded = true
                            model.downloadedURL = url
                        }
                    }
                }
                let tasks = await ModelManager.shared.allDownloadTasks
                for task in tasks {
                    if let url = task.originalRequest?.url?.absoluteString,
                       let model = models.first(where: { $0.url == url }) {
                        model.isDownloading = true
                    }
                }
                models.sort(by: { $1.name > $0.name })
                updates.models.removeAll()
                updates.models.append(contentsOf: models)
            }
        }
    }
}

#Preview {
    ModelsView()
}
