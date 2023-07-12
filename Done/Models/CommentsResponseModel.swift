// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let commentsResponseModel = try? JSONDecoder().decode(CommentsResponseModel.self, from: jsonData)

import Foundation
import UIKit

// MARK: - CommentsResponseModel
struct CommentsResponseModel: Codable {
    let status: Bool?
    let data: [CommentsData]?
}

// MARK: - Datum
struct CommentsData: Codable {
    var id, assigneeEmployeeID, createdAt, comment: String?
    let employeeID: String?
    let createdBy: String?
    let commenttype : String?
    let isLocalStore : Bool?
    let isLocalImageData : Data?
    
    enum CodingKeys: String, CodingKey {
        case id
        case assigneeEmployeeID = "assignee_employee_id"
        case createdAt = "created_at"
        case comment
        case employeeID = "employee_id"
        case createdBy = "created_by"
        case commenttype = "comment_type"
        case isLocalStore = "isLocalStore"
        case isLocalImageData = "isLocalImageData"
    }
}

// MARK: - PostCommentModel
struct PostCommentModel: Codable {
    
    let employeeID: String?
    let comment: String?
    let commenttype : String?
    let orderassigneeid : String?
    let taskcreatedby : String?

    enum CodingKeys: String, CodingKey {
 
        case employeeID = "employee_id"
        case comment
        case commenttype = "comment_type"
        case orderassigneeid = "order_assignee_id"
        case taskcreatedby = "task_created_by"
        
    }
}

// MARK: - PostMediaCommentModel
struct PostMediaCommentModel: Codable {
    let employeeID: String?
    let comment: String?
    let commenttype : String?
    let orderassigneeid : String?
    let taskCreatedBy : String?
    
    enum CodingKeys: String, CodingKey {
//        case assigneeEmployeeID = "assignee_employee_id"
        case employeeID = "employee_id"
        case comment
        case commenttype = "comment_type"
        case orderassigneeid = "order_assignee_id"
        case taskCreatedBy = "task_created_by"
    }
}

struct UpdateCommentRequestModel: Codable {
    let id: String?
    let comment : String?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case comment = "comment"
    }
}


struct DeleteCommentRequestModel: Codable {
    let id: String?
    let postID : String?
    let taskCreatedBy : String?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case postID = "post_id"
        case taskCreatedBy = "task_created_by"
    }
}
