//
//  GetGroupsResponseModel.swift
//  Done
//
//  Created by Mac on 10/07/23.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getGroupsResponseModel = try? JSONDecoder().decode(GetGroupsResponseModel.self, from: jsonData)

import Foundation

// MARK: - GetGroupsResponseModel
struct GetGroupsResponseModel: Codable {
    let status: Bool?
    let data: Data1?
}

// MARK: - DataClass
struct Data1: Codable {
    let groups: [Groups]?
}

// MARK: - Group
struct Groups: Codable {
    let id, name, createdAt: String?
    let updatedAt: String?
    let createdBy, createdByName: String?
    let employees: [Employees]?
    var isGroupSelected : Bool?

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case createdByName = "created_by_name"
        case employees
        case isGroupSelected
    }
}

// MARK: - Employee
struct Employees: Codable {
    let groupEmployeeID, employeeID, employeeName: String?

    enum CodingKeys: String, CodingKey {
        case groupEmployeeID = "group_employee_id"
        case employeeID = "employee_id"
        case employeeName = "employee_name"
    }
}
