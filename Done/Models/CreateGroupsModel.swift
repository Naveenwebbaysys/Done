//
//  CreateGroupsModel.swift
//  Done
//
//  Created by Sagar on 08/07/23.
//

import Foundation


// MARK: - CreateGroups Request Model
struct CreateGroupsRequestModel: Codable {
    let employees : [String]?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case employees = "employees"
        case name = "name"
    }
}

struct updateGroupsRequestModel: Codable {
    let employees : [String]?
    let name : String?
    let id : Int?
    
    enum CodingKeys: String, CodingKey {
        case employees = "employees"
        case name = "name"
        case id = "id"
    }
}

struct updateGroupsResponseModel: Codable {
    let status: Bool?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case id = "id"
    }
}
