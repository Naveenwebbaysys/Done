// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let updateDoneRequestModel = try? JSONDecoder().decode(UpdateDoneRequestModel.self, from: jsonData)

import Foundation

// MARK: - UpdateDoneRequestModel
struct UpdateDoneRequestModel: Codable {
    let postID, employeeID: Int?
    let taskStatus: String?
    let proofDescription: String?
    let proofDocument: String?
    let orderAssigneeID: Int?

    enum CodingKeys: String, CodingKey {
        case postID = "assignee_employee_id"
        case employeeID = "employee_id"
        case taskStatus = "task_status"
        case proofDescription = "proof_description"
        case proofDocument = "proof_document"
        case orderAssigneeID = "order_assignee_id"
    }
}
