//
//  ModelManager.swift
//  LLMKit
//
//  Created by Francis Li on 10/13/24.
//

import Foundation

public class ModelManager: NSObject, URLSessionDownloadDelegate {
    public static let shared = ModelManager()

    public var backgroundSessionIdentifier = "ModelManager"
    public var backgroundCompletionHandler: (() -> Void)?
    
    public weak var delegate: URLSessionDownloadDelegate?

    var fileManager: FileManager
    var modelDirectory: URL
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    public override init() {
        fileManager = FileManager.default
        let applicationSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        modelDirectory = URL(fileURLWithPath: "models", relativeTo: applicationSupportDirectory)
        if !fileManager.fileExists(atPath: modelDirectory.absoluteString) {
            try! fileManager.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
        }
    }
    
    public func list() throws -> [URL] {
        return try fileManager.contentsOfDirectory(at: modelDirectory, includingPropertiesForKeys: nil).filter{ $0.pathExtension.localizedLowercase == "gguf" }
    }

    public var allDownloads: [URLSessionTask] {
        get async {
            return await urlSession.allTasks
        }
    }

    public func download(_ url: URL) async {
        let tasks = await allDownloads
        for task in tasks {
            if task.originalRequest?.url == url {
                return
            }
        }
        let backgroundTask = urlSession.downloadTask(with: url)
        backgroundTask.countOfBytesClientExpectsToReceive = 10 * 1024 * 1024 * 1024
        backgroundTask.resume()
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [weak self] in
            self?.backgroundCompletionHandler?()
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let destURL = URL(fileURLWithPath: downloadTask.originalRequest!.url!.lastPathComponent, relativeTo: modelDirectory)
        print("done", location, "move to", destURL)
        try? fileManager.moveItem(at: location, to: destURL)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("progress", totalBytesWritten, totalBytesExpectedToWrite)
        delegate?.urlSession?(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}
