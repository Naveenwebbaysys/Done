//
//  CategoryResponseModel.swift
//  Done
//
//  Created by Sagar on 03/07/23.
//
import Foundation

// MARK: - CategoryResponseModel
struct CategoryResponseModel: Codable{
    let status: Bool
    let data: CategoryData
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case status = "status"
    }
}

// MARK: - DataClass
struct CategoryData: Codable {
    let categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case categories = "categories"
    }
}

// MARK: - Category
struct Category: Codable {
    let id, typeOfCategory, name, parentID: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case typeOfCategory = "type_of_category"
        case name = "name"
        case parentID = "parent_id"
    }
}
