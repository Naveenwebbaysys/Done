//
//  LoginModel.swift
//  Done
//
//  Created by Mac on 25/05/23.

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let loginResponseModel = try? JSONDecoder().decode(LoginResponseModel.self, from: jsonData)

import Foundation

// MARK: - LoginResponseModel
struct LoginResponseModel: Codable {
    let status: Bool?
    let message, department, accessToken: String?

    enum CodingKeys: String, CodingKey {
        case status, message, department
        case accessToken = "access_token"
    }
}

// MARK: - LoginRequestModel
struct LoginRequestModel: Encodable {
    let email, password: String?
    let isEmployee: Int?
}
