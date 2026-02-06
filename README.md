# Short Video Feed - iOS Tech Test

A TikTok-style vertical video feed app built with SwiftUI, featuring smooth scrolling, efficient video playback, and local like persistence.

## Features

-  Full-screen vertical video feed with swipe navigation
-  Autoplay with resource management
-  Like/comment/share UI with persistent likes
-  Profile screen with video grid
-  Efficient windowed loading (only 5 videos loaded at once)
-  Two-tier video caching (memory + disk)
-  Error handling with retry
-  Unit tests for core logic

## Setup Instructions

### Prerequisites
- Xcode 15.0+
- iOS 15.0+
- Pexels API key (free at https://www.pexels.com/api/)

### Installation

1. Clone the repository:
```bash
git clone <repo-url>
cd ios-video-app-test/ShortVideoFeed
```

2. Open the project:
```bash
open ShortVideoFeed.xcodeproj
```

3. Add your Pexels API key:
   - Open `Services/PexelsService.swift`
   - Replace `YOUR_PEXELS_API_KEY` with your actual API key

4. Build and run:
   - Select a simulator or device
   - Press `Cmd+R` to build and run

### Running Tests

```bash
# In Xcode
Cmd+U

# Or via command line
xcodebuild test -scheme ShortVideoFeed -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture Overview

### MVVM Pattern

```
Models/
├── Video.swift          # Video data model with Pexels JSON parsing
└── User.swift           # User profile model

Services/
├── PexelsService.swift  # API client for fetching videos
├── VideoCache.swift     # Two-tier caching (memory + disk)
└── LikeStore.swift      # UserDefaults persistence for likes

ViewModels/
├── VideoFeedViewModel.swift    # Feed state management
└── ProfileViewModel.swift      # Profile state management

Views/
├── VideoFeedView.swift         # Main feed with TabView paging
├── VideoPlayerView.swift       # Reusable AVPlayer component
├── ProfileView.swift           # Profile screen with video grid
└── ContentView.swift           # Tab navigation
```

### Key Design Decisions

**1. Windowed Loading**
- Only loads 5 videos at a time (current index ± 2)
- Prevents memory issues with 200+ videos
- Dynamically updates visible range as user scrolls

**2. Two-Tier Caching**
- **Memory cache**: NSCache for 10 most recent videos (instant playback)
- **Disk cache**: FileManager for downloaded videos (offline support)
- Videos download in background while streaming

**3. Resource Management**
- Videos pause and release AVPlayer when off-screen
- Automatic cleanup via `deinit` in VideoPlayerManager
- Prevents memory leaks and battery drain

**4. SwiftUI + Combine**
- Reactive state management with `@Published`
- Clean separation of concerns (View/ViewModel/Service)
- Native SwiftUI components (TabView, VideoPlayer)

## Tradeoffs and Limitations

### Current Tradeoffs

1. **Windowed Loading vs. Instant Access**
   - **Chosen**: Load 5 videos at a time
   - **Tradeoff**: Slight delay when jumping far in feed
   - **Benefit**: Smooth scrolling, low memory usage

2. **Disk Cache Without LRU Eviction**
   - **Chosen**: Simple cache without size limits
   - **Tradeoff**: Could fill device storage over time
   - **Benefit**: Faster implementation, good for demo

3. **Mock Profile Data**
   - **Chosen**: Random 12 videos for profile
   - **Tradeoff**: Not real user filtering
   - **Benefit**: Demonstrates UI without backend

4. **Local Like Persistence**
   - **Chosen**: UserDefaults for likes
   - **Tradeoff**: Not synced across devices
   - **Benefit**: Simple, works offline

### Known Limitations

- **No pagination**: Loads all 240 videos upfront (3 API calls)
- **No adaptive streaming**: Always uses HD quality
- **No real comments/share**: UI-only buttons
- **No user authentication**: Mock user data
- **No analytics**: No tracking of watch time/completion

## What I'd Improve With More Time

### Performance
- [ ] Implement true pagination (load 20 videos at a time)
- [ ] Add adaptive bitrate streaming (HLS)
- [ ] Implement LRU cache eviction with size limits
- [ ] Preload thumbnails for smoother grid scrolling

### Features
- [ ] Real user authentication and profiles
- [ ] Backend API for likes/comments/shares
- [ ] Video upload functionality
- [ ] Search and discovery
- [ ] Following/followers system
- [ ] Push notifications

### UX Polish
- [ ] Haptic feedback on like
- [ ] Smooth like animation (heart burst)
- [ ] Video progress indicator
- [ ] Double-tap to like
- [ ] Swipe gestures for actions

### Code Quality
- [ ] More comprehensive unit tests (90%+ coverage)
- [ ] UI tests for critical flows
- [ ] Dependency injection for testability
- [ ] Error logging/analytics
- [ ] Accessibility labels and VoiceOver support

### Infrastructure
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Crash reporting (Firebase Crashlytics)
- [ ] Performance monitoring
- [ ] A/B testing framework

## Technical Highlights

### Efficient Video Playback
```swift
// Windowed loading prevents memory issues
var visibleRange: Range<Int> {
    let start = max(0, currentIndex - 2)
    let end = min(videos.count, currentIndex + 3)
    return start..<end
}
```

### Smart Caching
```swift
// Two-tier cache: memory (fast) + disk (persistent)
func playerItem(for url: String) -> AVPlayerItem? {
    if let item = memoryCache.object(forKey: key) {
        return item  // Instant playback
    }
    if fileManager.fileExists(atPath: cacheURL.path) {
        return AVPlayerItem(url: cacheURL)  // Offline support
    }
    // Stream while downloading
    let item = AVPlayerItem(url: remoteURL)
    Task { await downloadVideo(from: url, to: cacheURL) }
    return item
}
```

### Resource Cleanup
```swift
// Automatic cleanup when video goes off-screen
.onDisappear {
    playerManager.pause()
}

deinit {
    player?.pause()
    player = nil
}
```

## Testing

### Unit Tests Coverage
-  Video JSON parsing (with/without optional fields)
-  LikeStore persistence and toggle logic
-  VideoFeedViewModel windowed loading
-  Edge cases (start/middle/end of feed)

### Test Results
```bash
Test Suite 'All tests' passed
    VideoModelTests: 2 tests, 0 failures
    LikeStoreTests: 4 tests, 0 failures
    VideoFeedViewModelTests: 4 tests, 0 failures
```

## API Usage

### Pexels API
- **Endpoint**: `https://api.pexels.com/videos/search`
- **Query**: `people`
- **Total videos**: 240 (3 pages × 80 per page)
- **Rate limit**: 200 requests/hour (free tier)

## License

This project is for demonstration purposes only.

## Contact

For questions or feedback, please reach out via the provided contact information.
