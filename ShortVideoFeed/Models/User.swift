import Foundation

struct User {
    let username: String
    let avatar: String?
    var videoCount: Int
    var totalLikes: Int
    
    static let mock = User(
        username: "johndoe",
        avatar: nil,
        videoCount: 0,
        totalLikes: 0
    )
}
