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

    enum CodingKeys: String, CodingKey {
        case id
        case assigneeEmployeeID = "assignee_employee_id"
        case createdAt = "created_at"
        case comment
        case employeeID = "employee_id"
        case createdBy = "created_by"
    }
}


