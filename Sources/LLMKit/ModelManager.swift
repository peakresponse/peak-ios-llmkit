//
//  ModelManager.swift
//  LLMKit
//
//  Created by Francis Li on 10/13/24.
//

import Foundation

public class ModelManager: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    public static let shared = ModelManager()

    public let backgroundSessionIdentifier = "ModelManager"
    public var backgroundCompletionHandler: (() -> Void)?
    
    public weak var delegate: URLSessionDownloadDelegate?

    let fileManager: FileManager
    let modelDirectory: URL

    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    public override init() {
        fileManager = FileManager.default
        let applicationSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var modelDirectory = URL(fileURLWithPath: "models", relativeTo: applicationSupportDirectory)
        if !fileManager.fileExists(atPath: modelDirectory.absoluteString) {
            try! fileManager.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
        }
        var resourceValues = try! modelDirectory.resourceValues(forKeys: [.isExcludedFromBackupKey])
        resourceValues.isExcludedFromBackup = true
        try! modelDirectory.setResourceValues(resourceValues)
        self.modelDirectory = modelDirectory
    }
    
    public func list() throws -> [URL] {
        return try fileManager.contentsOfDirectory(at: modelDirectory, includingPropertiesForKeys: nil).filter{ $0.pathExtension.localizedLowercase == "gguf" }
    }

    public var allDownloadTasks: [URLSessionTask] {
        get async {
            return await urlSession.allTasks
        }
    }
    
    public func delete(_ name: String) throws {
        try fileManager.removeItem(at: URL(fileURLWithPath: name, relativeTo: modelDirectory))
    }

    public func download(_ url: URL) async {
        let tasks = await allDownloadTasks
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
        var destURL = URL(fileURLWithPath: downloadTask.originalRequest!.url!.lastPathComponent, relativeTo: modelDirectory)
        try? fileManager.moveItem(at: location, to: destURL)
        var resourceValues = try! destURL.resourceValues(forKeys: [.isExcludedFromBackupKey])
        resourceValues.isExcludedFromBackup = true
        try! destURL.setResourceValues(resourceValues)
        delegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        delegate?.urlSession?(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}
