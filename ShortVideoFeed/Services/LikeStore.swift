import Foundation

class LikeStore {
    private let defaults = UserDefaults.standard
    private let likesKey = "video_likes"
    private let countsKey = "like_counts"
    
    func toggleLike(videoId: Int) {
        var likes = getLikedVideos()
        var counts = getLikeCounts()
        
        if likes.contains(videoId) {
            likes.remove(videoId)
            counts[videoId] = max(0, (counts[videoId] ?? 1) - 1)
        } else {
            likes.insert(videoId)
            counts[videoId] = (counts[videoId] ?? 0) + 1
        }
        
        saveLikedVideos(likes)
        saveLikeCounts(counts)
    }
    
    func isLiked(videoId: Int) -> Bool {
        getLikedVideos().contains(videoId)
    }
    
    func likeCount(videoId: Int) -> Int {
        getLikeCounts()[videoId] ?? 0
    }
    
    func totalLikes() -> Int {
        getLikeCounts().values.reduce(0, +)
    }
    
    private func getLikedVideos() -> Set<Int> {
        guard let data = defaults.data(forKey: likesKey),
              let likes = try? JSONDecoder().decode(Set<Int>.self, from: data) else {
            return []
        }
        return likes
    }
    
    private func saveLikedVideos(_ likes: Set<Int>) {
        if let data = try? JSONEncoder().encode(likes) {
            defaults.set(data, forKey: likesKey)
        }
    }
    
    private func getLikeCounts() -> [Int: Int] {
        guard let data = defaults.data(forKey: countsKey),
              let counts = try? JSONDecoder().decode([Int: Int].self, from: data) else {
            return [:]
        }
        return counts
    }
    
    private func saveLikeCounts(_ counts: [Int: Int]) {
        if let data = try? JSONEncoder().encode(counts) {
            defaults.set(data, forKey: countsKey)
        }
    }
}
