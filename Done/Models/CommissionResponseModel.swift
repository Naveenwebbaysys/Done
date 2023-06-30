// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let commissionResponseModel = try? JSONDecoder().decode(CommissionResponseModel.self, from: jsonData)

import Foundation

// MARK: - CommissionResponseModel
struct CommissionResponseModel: Codable {
    let status: Bool?
    let data: CommissionData?
}

// MARK: - DataClass
struct CommissionData: Codable {
    let stillWorkingCommission, doneCommission, assignedByCommission, approvedcommission: Commission?

    enum CodingKeys: String, CodingKey {
        case stillWorkingCommission = "still_working_commission"
        case doneCommission = "done_commission"
        case assignedByCommission = "assigned_by_commission"
        case approvedcommission = "approved_commission"
    }
}

// MARK: - Commission
struct Commission: Codable {
    let commission, commissionCount: String?

    enum CodingKeys: String, CodingKey {
        case commission
        case commissionCount = "commission_count"
    }
}
