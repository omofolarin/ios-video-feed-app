import XCTest
@testable import ShortVideoFeed

final class LikeStoreTests: XCTestCase {
    var likeStore: LikeStore!
    
    override func setUp() {
        super.setUp()
        likeStore = LikeStore()
        // Clear any existing data
        UserDefaults.standard.removeObject(forKey: "video_likes")
        UserDefaults.standard.removeObject(forKey: "like_counts")
    }
    
    func testToggleLike() {
        let videoId = 123
        
        // Initially not liked
        XCTAssertFalse(likeStore.isLiked(videoId: videoId))
        XCTAssertEqual(likeStore.likeCount(videoId: videoId), 0)
        
        // Like the video
        likeStore.toggleLike(videoId: videoId)
        XCTAssertTrue(likeStore.isLiked(videoId: videoId))
        XCTAssertEqual(likeStore.likeCount(videoId: videoId), 1)
        
        // Unlike the video
        likeStore.toggleLike(videoId: videoId)
        XCTAssertFalse(likeStore.isLiked(videoId: videoId))
        XCTAssertEqual(likeStore.likeCount(videoId: videoId), 0)
    }
    
    func testMultipleLikes() {
        likeStore.toggleLike(videoId: 1)
        likeStore.toggleLike(videoId: 2)
        likeStore.toggleLike(videoId: 3)
        
        XCTAssertTrue(likeStore.isLiked(videoId: 1))
        XCTAssertTrue(likeStore.isLiked(videoId: 2))
        XCTAssertTrue(likeStore.isLiked(videoId: 3))
        XCTAssertEqual(likeStore.totalLikes(), 3)
    }
    
    func testPersistence() {
        let videoId = 456
        likeStore.toggleLike(videoId: videoId)
        
        // Create new instance to test persistence
        let newStore = LikeStore()
        XCTAssertTrue(newStore.isLiked(videoId: videoId))
        XCTAssertEqual(newStore.likeCount(videoId: videoId), 1)
    }
}
