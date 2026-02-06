import Foundation

enum PexelsError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
}

class PexelsService {
    private let apiKey = "e3SY7xHQSFntkEUwmeWAihiT131oYtyHTIOTxagzvdlPBRPMhu3k4Iwv"
    private let baseURL = "https://api.pexels.com/videos/search"
    
    func fetchVideos() async throws -> [Video] {
        var allVideos: [Video] = []
        
        // Fetch 1 page (80 videos) to avoid duplicates
        let videos = try await fetchPage(page: 1, perPage: 80)
        allVideos.append(contentsOf: videos)
        
        return allVideos
    }
    
    private func fetchPage(page: Int, perPage: Int) async throws -> [Video] {
        guard var components = URLComponents(string: baseURL) else {
            throw PexelsError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "query", value: "people"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components.url else {
            throw PexelsError.invalidURL
        }
        
        print("🌐 Fetching: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status: \(httpResponse.statusCode)")
            }
            
            print("📦 Data size: \(data.count) bytes")
            
            let decoded = try JSONDecoder().decode(PexelsResponse.self, from: data)
            print("✅ Parsed \(decoded.videos.count) videos")
            return decoded.videos
        } catch let error as DecodingError {
            print("❌ Decoding error: \(error)")
            throw PexelsError.decodingError(error)
        } catch {
            print("❌ Network error: \(error)")
            throw PexelsError.networkError(error)
        }
    }
}

struct PexelsResponse: Codable {
    let videos: [Video]
}
