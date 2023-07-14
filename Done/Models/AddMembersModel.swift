//
//  AddMembersModel.swift
//  Done
//
//  Created by Mac on 14/07/23.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let addMembersModel = try? JSONDecoder().decode(AddMembersModel.self, from: jsonData)

import Foundation

// MARK: - AddMembersModel
struct AddMembersModel: Codable {
    let id: String?
    let tagPeoples: [Int]?

    enum CodingKeys: String, CodingKey {
        case id
        case tagPeoples = "tag_peoples"
    }
}
