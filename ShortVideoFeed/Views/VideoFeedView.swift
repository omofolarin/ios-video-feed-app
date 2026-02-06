import SwiftUI

struct VideoFeedView: View {
    @StateObject private var viewModel = VideoFeedViewModel()
    @State private var selectedVideoForProfile: Video?
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                Color.black.ignoresSafeArea()
                ProgressView()
                    .tint(.white)
            } else if let error = viewModel.error {
                Color.black.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    Text("Failed to load videos")
                        .foregroundColor(.white)
                    Text(error.localizedDescription)
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        viewModel.retryLoading()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<viewModel.videos.count, id: \.self) { index in
                                let video = viewModel.videos[index]
                                VideoItemView(
                                    video: video,
                                    isLiked: viewModel.isLiked(video),
                                    likeCount: viewModel.likeCount(for: video),
                                    onLike: { viewModel.toggleLike(for: video) },
                                    onUsernameTap: { selectedVideoForProfile = video }
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .id(index)
                            }
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .ignoresSafeArea()
                }
                .ignoresSafeArea()
            }
        }
        .task {
            await viewModel.loadVideos()
        }
        .sheet(item: $selectedVideoForProfile) { video in
            ProfileView(allVideos: viewModel.videos)
        }
    }
}

struct VideoItemView: View {
    let video: Video
    let isLiked: Bool
    let likeCount: Int
    let onLike: () -> Void
    let onUsernameTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                VideoPlayerView(video: video)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Overlay UI
                VStack(alignment: .leading, spacing: 12) {
                    Spacer()
                    
                    // Username
                    Button(action: onUsernameTap) {
                        Text("@\(video.username)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    // Caption
                    if let caption = video.caption {
                        Text(caption)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                }
                .padding(.leading, 16)
                .padding(.bottom, 80)
                
                // Action buttons
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Like button
                    VStack(spacing: 4) {
                        Button(action: onLike) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 32))
                                .foregroundColor(isLiked ? .red : .white)
                        }
                        Text("\(likeCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    // Comment button
                    VStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        Text("0")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    // Share button
                    VStack(spacing: 4) {
                        Image(systemName: "arrowshape.turn.up.right")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        Text("Share")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 80)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
