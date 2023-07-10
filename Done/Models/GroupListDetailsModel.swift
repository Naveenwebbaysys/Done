//
//  GroupListDetailsModel.swift
//  Done
//
//  Created by Sagar on 10/07/23.
//

import Foundation

// MARK: - GroupListDetails
struct GroupListDetails: Codable {
    let status: Bool?
    let data: GroupListData?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case data = "data"
    }
}

// MARK: - DataClass
struct GroupListData: Codable  {
    let groups: [Group]?
    
    enum CodingKeys: String, CodingKey {
        case groups = "groups"
    }
}

// MARK: - Group
struct Group: Codable {
    let id, name, createdAt: String?
    let updatedAt: String?
    let createdBy, createdByName: String?
    let employees: [GroupEmployee]?
   
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case createdByName = "created_by_name"
        case employees = "employees"
    }
}

// MARK: - Employee
struct GroupEmployee: Codable {
    let groupEmployeeID, employeeID, employeeName: String?
    
    enum CodingKeys: String, CodingKey {
        case groupEmployeeID = "group_employee_id"
        case employeeID = "employee_id"
        case employeeName = "employee_name"
    }
}
