import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVideo: Video?
    
    let allVideos: [Video]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        // Avatar
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                        
                        // Username
                        Text("@\(viewModel.user.username)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Stats
                        HStack(spacing: 32) {
                            StatView(title: "Videos", value: "\(viewModel.user.videoCount)")
                            StatView(title: "Likes", value: "\(viewModel.user.totalLikes)")
                        }
                    }
                    .padding(.top, 24)
                    
                    Divider()
                    
                    // Video grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2)
                    ], spacing: 2) {
                        ForEach(viewModel.userVideos) { video in
                            Button {
                                selectedVideo = video
                            } label: {
                                AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipped()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 200)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadProfile(allVideos: allVideos)
        }
        .fullScreenCover(item: $selectedVideo) { video in
            VideoPlayerView(video: video)
                .overlay(alignment: .topLeading) {
                    Button {
                        selectedVideo = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                .ignoresSafeArea()
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
