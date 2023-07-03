//
//  PostRequestModel.swift
//  Done
//
//  Created by Mac on 05/06/23.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let postRequestModel = try? JSONDecoder().decode(PostRequestModel.self, from: jsonData)

import Foundation

// MARK: - PostRequestModel
struct PostRequestModel: Codable {
    let videoURL: String?
    let tagPeoples: [String]?
    let addLinks, tags: [String]?
    let videoRestriction, description, assignedDate, commissionType: String?
    let commissionAmount: String?
    let dueDate: String?
    let categoryId: String?
    let subcategoryId: String?
    let projectType: String?
    

    enum CodingKeys: String, CodingKey {
        case videoURL = "video_url"
        case tagPeoples = "tag_peoples"
        case addLinks = "add_links"
        case tags
        case videoRestriction = "video_restriction"
        case description
        case assignedDate = "assigned_date"
        case commissionType = "commission_type"
        case commissionAmount = "commission_amount"
        case dueDate = "due_date"
        case categoryId = "category_id"
        case subcategoryId = "subcategory_id"
        case projectType = "project_type"
        
    }
}




// MARK: - PostResponseModel
struct PostResponseModel: Codable {
    let status: Bool?
    let id: String?
}


// MARK: - PostRequestModel
struct UpdatePostRequestModel: Codable {
    let videoURL: String?
    let tagPeoples: [String]?
    let addLinks, tags: [String]?
    let videoRestriction, description, commissionType: String?
    let commissionAmount: String?
    let dueDate: String?
    let id : String?
    let categoryId: String?
    let subcategoryId: String?
    let projectType: String?

    enum CodingKeys: String, CodingKey {
        case videoURL = "video_url"
        case tagPeoples = "tag_peoples"
        case addLinks = "add_links"
        case tags
        case videoRestriction = "video_restriction"
        case description
//        case assignedDate = "assigned_date"
        case commissionType = "commission_type"
        case commissionAmount = "commission_amount"
        case dueDate = "due_date"
        case id
        case categoryId = "category_id"
        case subcategoryId = "subcategory_id"
        case projectType = "project_type"
    }
}
