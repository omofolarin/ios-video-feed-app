import XCTest
@testable import ShortVideoFeed

@MainActor
final class VideoFeedViewModelTests: XCTestCase {
    var viewModel: VideoFeedViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = VideoFeedViewModel()
    }
    
    func testVisibleRangeAtStart() {
        viewModel.videos = Array(repeating: createMockVideo(), count: 100)
        viewModel.currentIndex = 0
        
        let range = viewModel.visibleRange
        XCTAssertEqual(range.lowerBound, 0)
        XCTAssertEqual(range.upperBound, 3)
    }
    
    func testVisibleRangeInMiddle() {
        viewModel.videos = Array(repeating: createMockVideo(), count: 100)
        viewModel.currentIndex = 50
        
        let range = viewModel.visibleRange
        XCTAssertEqual(range.lowerBound, 48)
        XCTAssertEqual(range.upperBound, 53)
    }
    
    func testVisibleRangeAtEnd() {
        viewModel.videos = Array(repeating: createMockVideo(), count: 100)
        viewModel.currentIndex = 99
        
        let range = viewModel.visibleRange
        XCTAssertEqual(range.lowerBound, 97)
        XCTAssertEqual(range.upperBound, 100)
    }
    
    func testLikeToggle() {
        let video = createMockVideo(id: 789)
        viewModel.videos = [video]
        
        XCTAssertFalse(viewModel.isLiked(video))
        
        viewModel.toggleLike(for: video)
        XCTAssertTrue(viewModel.isLiked(video))
        XCTAssertEqual(viewModel.likeCount(for: video), 1)
        
        viewModel.toggleLike(for: video)
        XCTAssertFalse(viewModel.isLiked(video))
    }
    
    private func createMockVideo(id: Int = 1) -> Video {
        Video(
            id: id,
            videoUrl: "https://example.com/video.mp4",
            thumbnailUrl: "https://example.com/thumb.jpg",
            username: "testuser",
            duration: 30
        )
    }
}
