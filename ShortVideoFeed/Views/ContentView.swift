import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var feedViewModel = VideoFeedViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VideoFeedView()
                .tabItem {
                    Label("Feed", systemImage: "play.rectangle.fill")
                }
                .tag(0)
            
            ProfileView(allVideos: feedViewModel.videos)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
        }
        .task {
            await feedViewModel.loadVideos()
        }
    }
}

#Preview {
    ContentView()
}
