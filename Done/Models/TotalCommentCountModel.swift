// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let totalCommentCountModel = try? JSONDecoder().decode(TotalCommentCountModel.self, from: jsonData)

import Foundation

// MARK: - TotalCommentCountModel
struct TotalCommentCountModel: Codable {
    let status: Bool?
    let assigneeComments: [AssigneeComment]?
    let totalComments: [TotalComment]?

    enum CodingKeys: String, CodingKey {
        case status
        case assigneeComments = "assignee_comments"
        case totalComments = "total_comments"
    }
}

// MARK: - AssigneeComment
struct AssigneeComment: Codable {
    let assigneecomments, assigneeEmployeeID: String?

    enum CodingKeys: String, CodingKey {
        case assigneecomments
        case assigneeEmployeeID = "assignee_employee_id"
    }
}

// MARK: - TotalComment
struct TotalComment: Codable {
    let totalCommentsCount: String?

    enum CodingKeys: String, CodingKey {
        case totalCommentsCount = "total_comments_count"
    }
}

