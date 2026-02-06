import Foundation
import AVFoundation

class VideoCache {
    static let shared = VideoCache()
    
    private let memoryCache = NSCache<NSString, AVPlayerItem>()
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL = {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDir = paths[0].appendingPathComponent("VideoCache")
        try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        return cacheDir
    }()
    
    init() {
        memoryCache.countLimit = 10 // Keep 10 videos in memory
    }
    
    func playerItem(for url: String) -> AVPlayerItem? {
        let key = url as NSString
        
        // Check disk cache first
        let cacheURL = cacheDirectory.appendingPathComponent(url.md5)
        if fileManager.fileExists(atPath: cacheURL.path) {
            // Always create new item from cached file
            return AVPlayerItem(url: cacheURL)
        }
        
        // Create new item from remote URL
        guard let videoURL = URL(string: url) else { return nil }
        let item = AVPlayerItem(url: videoURL)
        
        // Download to disk cache in background
        Task {
            await downloadVideo(from: url, to: cacheURL)
        }
        
        return item
    }
    
    private func downloadVideo(from urlString: String, to destination: URL) async {
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (tempURL, _) = try await URLSession.shared.download(from: url)
            try? fileManager.moveItem(at: tempURL, to: destination)
        } catch {
            print("Failed to cache video: \(error)")
        }
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
    }
}

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { bytes -> String in
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        }
        return hash
    }
}

import CommonCrypto
