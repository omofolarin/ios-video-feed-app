import XCTest
@testable import ShortVideoFeed

final class VideoModelTests: XCTestCase {
    
    func testVideoJSONParsing() throws {
        let json = """
        {
            "id": 123,
            "duration": 30,
            "video_files": [
                {
                    "quality": "hd",
                    "link": "https://example.com/video.mp4"
                }
            ],
            "image": {
                "large": "https://example.com/thumb.jpg"
            },
            "user": {
                "name": "John Doe"
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let video = try JSONDecoder().decode(Video.self, from: data)
        
        XCTAssertEqual(video.id, 123)
        XCTAssertEqual(video.duration, 30)
        XCTAssertEqual(video.videoUrl, "https://example.com/video.mp4")
        XCTAssertEqual(video.thumbnailUrl, "https://example.com/thumb.jpg")
        XCTAssertEqual(video.username, "John Doe")
    }
    
    func testVideoJSONParsingWithMissingFields() throws {
        let json = """
        {
            "id": 456,
            "duration": 45,
            "video_files": [
                {
                    "quality": "sd",
                    "link": "https://example.com/video2.mp4"
                }
            ],
            "image": {},
            "user": {}
        }
        """
        
        let data = json.data(using: .utf8)!
        let video = try JSONDecoder().decode(Video.self, from: data)
        
        XCTAssertEqual(video.id, 456)
        XCTAssertEqual(video.videoUrl, "https://example.com/video2.mp4")
        XCTAssertEqual(video.username, "Unknown")
        XCTAssertEqual(video.thumbnailUrl, "")
    }
}
