// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let viewStatusResponseModel = try? JSONDecoder().decode(ViewStatusResponseModel.self, from: jsonData)

import Foundation

// MARK: - ViewStatusResponseModel
struct ViewStatusResponseModel: Codable {
    let status: Bool?
    let data: ViewStatusRespose?
}

// MARK: - DataClass
struct ViewStatusRespose: Codable {
    let stillWorkingPosts, donePosts: [PostStatus]?

    enum CodingKeys: String, CodingKey {
        case stillWorkingPosts = "still_working_posts"
        case donePosts = "done_posts"
    }
}

// MARK: - Post
struct PostStatus: Codable {
    let postID, orderAssigneeEmployeeID, status, employeeID: String?
    let employeeName: String?
    let lastmessage: String?
    let commentscount: String?
    

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case orderAssigneeEmployeeID = "order_assignee_employee_id"
        case status
        case employeeID = "employee_id"
        case employeeName = "employee_name"
        case lastmessage = "last_message"
        case commentscount = "comments_count"
    }
}


