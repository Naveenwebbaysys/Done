//
//  MembersModel.swift
//  Done
//
//  Created by Mac on 14/07/23.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let membersModel = try? JSONDecoder().decode(MembersModel.self, from: jsonData)

import Foundation

// MARK: - MembersModel
struct MembersModel: Codable {
    let status: Bool?
    let data: [Member]?
}

// MARK: - Datum
struct Member: Codable {
    let firstName, lastName, id, departmentName: String?
    var isSelected : Bool?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case id
        case departmentName = "department_name"
        case isSelected
    }
}
