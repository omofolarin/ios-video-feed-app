import Foundation

struct Video: Identifiable, Codable {
    let id: Int
    let videoUrl: String
    let thumbnailUrl: String
    let username: String
    let duration: Int
    var caption: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case videoFiles = "video_files"
        case image
        case user
        case duration
        case videoUrl
        case thumbnailUrl
        case username
        case caption
    }
    
    init(id: Int, videoUrl: String, thumbnailUrl: String, username: String, duration: Int, caption: String? = nil) {
        self.id = id
        self.videoUrl = videoUrl
        self.thumbnailUrl = thumbnailUrl
        self.username = username
        self.duration = duration
        self.caption = caption
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        duration = try container.decode(Int.self, forKey: .duration)
        
        // Parse video files to get HD quality URL
        let videoFiles = try container.decode([[String: AnyCodable]].self, forKey: .videoFiles)
        videoUrl = videoFiles.first(where: { $0["quality"]?.value as? String == "hd" })?["link"]?.value as? String
            ?? videoFiles.first?["link"]?.value as? String
            ?? ""
        
        // Parse thumbnail - can be string or dictionary
        if let imageString = try? container.decode(String.self, forKey: .image) {
            thumbnailUrl = imageString
        } else if let imageDict = try? container.decode([String: String].self, forKey: .image) {
            thumbnailUrl = imageDict["large"] ?? imageDict["medium"] ?? ""
        } else {
            thumbnailUrl = ""
        }
        
        // Parse user - use AnyCodable for mixed types
        let user = try container.decode([String: AnyCodable].self, forKey: .user)
        username = user["name"]?.value as? String ?? "Unknown"
        
        caption = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(videoUrl, forKey: .videoUrl)
        try container.encode(thumbnailUrl, forKey: .thumbnailUrl)
        try container.encode(username, forKey: .username)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(caption, forKey: .caption)
    }
}

// Helper for decoding dynamic JSON
struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        }
    }
}
