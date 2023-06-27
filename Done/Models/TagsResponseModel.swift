// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let tagsResponseModel = try? JSONDecoder().decode(TagsResponseModel.self, from: jsonData)

import Foundation

// MARK: - TagsResponseModel
struct TagsResponseModel: Codable {
    let status: Bool?
    let data: [TagUsers]?
}

// MARK: - Datum
struct TagUsers: Codable {
    let departmentName, id, firstName, lastName: String?
    var isSelected : Bool?

    enum CodingKeys: String, CodingKey {
        case departmentName = "department_name"
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case isSelected
    }
}
