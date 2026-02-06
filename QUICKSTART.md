# Quick Start Guide

## Option 1: Create New Xcode Project (Recommended)

1. **Open Xcode** → File → New → Project
2. **Select**: iOS → App
3. **Configure**:
   - Product Name: `ShortVideoFeed`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Minimum Deployment: `iOS 15.0`
4. **Save** to: `/Users/omofolarin/Documents/personal-dev/ios-video-app-test/`

5. **Copy source files**:
   ```bash
   # Delete default files
   rm ShortVideoFeed/ContentView.swift
   rm ShortVideoFeed/ShortVideoFeedApp.swift
   
   # Copy all source files
   cp -r ShortVideoFeed/ShortVideoFeed/* YourNewProject/ShortVideoFeed/
   ```

6. **Add API Key**:
   - Open `Services/PexelsService.swift`
   - Replace `YOUR_PEXELS_API_KEY` with your key from https://www.pexels.com/api/

7. **Build and Run**: `Cmd+R`

## Option 2: Use Provided Structure

The source files are already organized in the correct structure. You can:

1. Create a new Xcode project as above
2. Drag and drop the folders into Xcode:
   - Models/
   - Services/
   - ViewModels/
   - Views/
3. Make sure "Copy items if needed" is checked
4. Add your Pexels API key
5. Build and run

## Getting a Pexels API Key

1. Go to https://www.pexels.com/api/
2. Click "Get Started"
3. Sign up (free)
4. Copy your API key
5. Paste it in `Services/PexelsService.swift`

## Testing

Run tests with `Cmd+U` or:
```bash
xcodebuild test -scheme ShortVideoFeed -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Troubleshooting

### "No such module 'ShortVideoFeed'" in tests
- Make sure the test target has access to the main target
- Check Target Membership in File Inspector

### Videos not loading
- Check your API key is correct
- Check network connection
- Check Xcode console for error messages

### Build errors
- Clean build folder: `Cmd+Shift+K`
- Delete derived data: `Cmd+Option+Shift+K`
- Restart Xcode

## Project Structure

```
ShortVideoFeed/
├── ShortVideoFeed/
│   ├── Models/
│   │   ├── Video.swift
│   │   └── User.swift
│   ├── Services/
│   │   ├── PexelsService.swift
│   │   ├── VideoCache.swift
│   │   └── LikeStore.swift
│   ├── ViewModels/
│   │   ├── VideoFeedViewModel.swift
│   │   └── ProfileViewModel.swift
│   ├── Views/
│   │   ├── VideoFeedView.swift
│   │   ├── VideoPlayerView.swift
│   │   ├── ProfileView.swift
│   │   └── ContentView.swift
│   ├── ShortVideoFeedApp.swift
│   └── Info.plist
├── ShortVideoFeedTests/
│   ├── VideoModelTests.swift
│   ├── LikeStoreTests.swift
│   └── VideoFeedViewModelTests.swift
└── README.md
```

## Next Steps

1. Get the app running locally
2. Test on simulator
3. Archive for TestFlight
4. Submit for review

See README.md for full documentation.
