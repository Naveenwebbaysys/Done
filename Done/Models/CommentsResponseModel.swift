// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let commentsResponseModel = try? JSONDecoder().decode(CommentsResponseModel.self, from: jsonData)

import Foundation

// MARK: - CommentsResponseModel
struct CommentsResponseModel: Codable {
    let status: Bool?
    let data: [CommentsData]?
}

// MARK: - Datum
struct CommentsData: Codable {
    let id, assigneeEmployeeID, createdAt, comment: String?
    let employeeID: String?
    let createdBy: String?
    let commenttype : String?

    enum CodingKeys: String, CodingKey {
        case id
        case assigneeEmployeeID = "assignee_employee_id"
        case createdAt = "created_at"
        case comment
        case employeeID = "employee_id"
        case createdBy = "created_by"
        case commenttype = "comment_type"
    }
}

// MARK: - PostCommentModel
struct PostCommentModel: Codable {
    let assigneeEmployeeID, employeeID: Int?
    let comment: String?
    let commenttype : String?
    let assigneeid : String?

    enum CodingKeys: String, CodingKey {
        case assigneeEmployeeID = "assignee_employee_id"
        case employeeID = "employee_id"
        case comment
        case commenttype = "comment_type"
        case assigneeid = "assignee_id"
    }
}

// MARK: - PostMediaCommentModel
struct PostMediaCommentModel: Codable {
    let assigneeEmployeeID, employeeID: Int?
    let comment: String?
    let commenttype : String?
    let assigneeid : String?
    let taskCreatedBy : String?
    
    enum CodingKeys: String, CodingKey {
        case assigneeEmployeeID = "assignee_employee_id"
        case employeeID = "employee_id"
        case comment
        case commenttype = "comment_type"
        case assigneeid = "assignee_id"
        case taskCreatedBy = "task_created_by"
    }
}

