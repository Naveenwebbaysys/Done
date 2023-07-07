//
//  AssigneeResponseModel.swift
//  Done
//
//  Created by Sagar on 07/07/23.
//

import Foundation

// MARK: - AssigneeResponseModel
struct AssigneeResponseModel: Codable {
    let status: Bool?
    let creatorsList, assigneeList: [List]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case creatorsList = "creators_list"
        case assigneeList = "assignee_list"
    }
}

// MARK: - List
struct List: Codable {
    let firstName, id: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case id = "id"
    }
}
