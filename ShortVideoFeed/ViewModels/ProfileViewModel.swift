import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var userVideos: [Video] = []
    
    private let likeStore = LikeStore()
    
    init() {
        self.user = User.mock
    }
    
    func loadProfile(allVideos: [Video]) {
        // Get random 12 videos for profile
        userVideos = Array(allVideos.shuffled().prefix(12))
        
        // Update user stats
        user.videoCount = allVideos.count
        user.totalLikes = likeStore.totalLikes()
    }
    
    func refreshStats() {
        user.totalLikes = likeStore.totalLikes()
    }
}
