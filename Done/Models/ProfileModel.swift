
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let profileResponseModel = try? JSONDecoder().decode(ProfileResponseModel.self, from: jsonData)

import Foundation

// MARK: - ProfileResponseModel




struct ProfileResponseModel: Codable {
    let status: Bool?
    let employee: Employee?
}

// MARK: - Employee
struct Employee: Codable {
    let id, firstName, lastName, email: String?
    let companyEmail, onlineStatus, department: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case companyEmail = "company_email"
        case onlineStatus = "online_status"
        case department
    }
}
