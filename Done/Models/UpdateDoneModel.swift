// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let updateDoneRequestModel = try? JSONDecoder().decode(UpdateDoneRequestModel.self, from: jsonData)

import Foundation

// MARK: - UpdateDoneRequestModel
struct UpdateDoneRequestModel: Codable {
    let postID, employeeID: Int?
    let taskStatus: String?

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case employeeID = "employee_id"
        case taskStatus = "task_status"
    }
}
