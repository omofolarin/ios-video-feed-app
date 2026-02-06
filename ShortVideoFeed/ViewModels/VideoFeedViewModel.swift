import Foundation
import Combine

@MainActor
class VideoFeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentIndex = 0
    
    private let pexelsService = PexelsService()
    private let likeStore = LikeStore()
    
    var visibleRange: Range<Int> {
        let start = max(0, currentIndex - 5)
        let end = min(videos.count, currentIndex + 6)
        return start..<end
    }
    
    func loadVideos() async {
        isLoading = true
        error = nil
        
        do {
            videos = try await pexelsService.fetchVideos()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func toggleLike(for video: Video) {
        likeStore.toggleLike(videoId: video.id)
        objectWillChange.send()
    }
    
    func isLiked(_ video: Video) -> Bool {
        likeStore.isLiked(videoId: video.id)
    }
    
    func likeCount(for video: Video) -> Int {
        likeStore.likeCount(videoId: video.id)
    }
    
    func retryLoading() {
        Task {
            await loadVideos()
        }
    }
}
