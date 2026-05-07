//
//  ModelsView.swift
//  LLMKit_Example
//
//  Created by Francis Li on 10/13/24.
//

import LLMKit
import SwiftUI

struct ModelView: View {
    @ObservedObject var model: Model
    @State var showDeleteConfirmation = false

    var body: some View {
        HStack {
            if model.type != .gguf {
                Image(systemName: "cloud.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 28)
            } else if model.isDownloaded {
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
                        if model.type != .gguf || model.isDownloaded {
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
                let models: [Model] = [
                    Model(
                        id: "Llama-3.2-1B-Instruct.Q4_K_M.gguf",
                        name: "llama-3.2-1B-Instruct.Q4_K_M.gguf",
                        template: .llama3("You are an expert medical secretary."),
                        url: "https://huggingface.co/QuantFactory/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct.Q4_K_M.gguf?download=true"),
                    Model(type: .awsBedrock,
                          id: "us.meta.llama3-3-70b-instruct-v1:0",
                          name: "AWS Bedrock US Meta Llama 3.3 70B Instruct",
                          template: .llama3("You are an expert medical secretary."))
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
                updates.models.removeAll()
                updates.models.append(contentsOf: models)
            }
        }
    }
}

#Preview {
    ModelsView()
}
