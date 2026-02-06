import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let video: Video
    @StateObject private var playerManager: VideoPlayerManager
    
    init(video: Video) {
        self.video = video
        _playerManager = StateObject(wrappedValue: VideoPlayerManager(videoUrl: video.videoUrl))
    }
    
    var body: some View {
        ZStack {
            if playerManager.isLoading {
                Color.black
                ProgressView()
                    .tint(.white)
            } else if let error = playerManager.error {
                Color.black
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    Text("Failed to load video")
                        .foregroundColor(.white)
                    Button("Retry") {
                        playerManager.retry()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else if let player = playerManager.player {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onAppear {
                        playerManager.play()
                    }
                    .onDisappear {
                        playerManager.pause()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

@MainActor
class VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isLoading = true
    @Published var error: Error?
    
    private let videoUrl: String
    private var playerItem: AVPlayerItem?
    
    init(videoUrl: String) {
        self.videoUrl = videoUrl
        setupPlayer()
    }
    
    private func setupPlayer() {
        guard let videoURL = URL(string: videoUrl) else {
            error = NSError(domain: "VideoPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid video URL"])
            isLoading = false
            return
        }
        
        // Create player item directly from URL (no caching for now)
        let item = AVPlayerItem(url: videoURL)
        playerItem = item
        player = AVPlayer(playerItem: item)
        
        // Observe player status
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.player?.seek(to: .zero)
                self.player?.play()
            }
        }
        
        // Monitor loading status
        item.publisher(for: \.status)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.isLoading = false
                    self?.error = nil
                case .failed:
                    self?.error = item.error
                    self?.isLoading = false
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func retry() {
        isLoading = true
        error = nil
        setupPlayer()
    }
    
    deinit {
        Task { @MainActor [weak self] in
            self?.player?.pause()
            self?.player = nil
        }
    }
}

import Combine
