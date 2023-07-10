//
//  GroupCreateVM.swift
//  Done
//
//  Created by Sagar on 08/07/23.
//

import Foundation
import UIKit
import KRProgressHUD

class GroupCreateVM: NSObject {
    
    static let shared = GroupCreateVM()
    var controller : UIViewController?
    
    func addGroupsAPICall(employeesID : [String],stName:String,tagPeoplesName:[String]){
        let postparams = CreateGroupsRequestModel(employees: employeesID, name: stName)
                print("Request parameter==",postparams)
        //            print("This is run on the background queue")
        KRProgressHUD.show()
        APIModel.backGroundPostRequest(strURL: BASEURL + GROUPSAPI as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { jsonResult in
            KRProgressHUD.dismiss()
            self.controller?.navigationController?.popViewController(animated: true)
           
            let groupResponseModel = try? JSONDecoder().decode(updateGroupsResponseModel.self, from: jsonResult as! Data)
            if let viewGrpData = self.controller as? GroupCreateViewController{
                var arrDataOfEmp = [GroupEmployee]()
                for (index,data) in employeesID.enumerated(){
                    let emp = GroupEmployee(groupEmployeeID: "", employeeID: data, employeeName: tagPeoplesName[index])
                    arrDataOfEmp.append(emp)
                }
              
                let newgrp = Group(id: groupResponseModel?.id ?? "", name: stName, createdAt: "", updatedAt: "", createdBy: "", createdByName: "", employees: arrDataOfEmp)
                viewGrpData.delegate?.setUpdateOfGroup(dataOfGrp: newgrp, selectedIndex: viewGrpData.selectedGroupIndex ?? 0, isUpdate: false)
            }
        } failureHandler: { error in
            print(error)
        }
        DispatchQueue.main.async {
            print("This is run on the main queue, after the previous code in outer block")
        }
    }
    
    func editGroupsAPICall(employeesID : [String],stName:String,id:Int,tagPeoplesName:[String]){
        let postparams = updateGroupsRequestModel(employees: employeesID, name: stName, id: id)
                print("Request parameter==",postparams)
        //            print("This is run on the background queue")
        KRProgressHUD.show()
        APIModel.putRequest(strURL: BASEURL + GROUPSAPI as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { jsonResult in
            KRProgressHUD.dismiss()
            self.controller?.navigationController?.popViewController(animated: true)
            let groupResponseModel = try? JSONDecoder().decode(updateGroupsResponseModel.self, from: jsonResult as! Data)
            if let viewGrpData = self.controller as? GroupCreateViewController{
                var arrDataOfEmp = [GroupEmployee]()
                for (index,data) in employeesID.enumerated(){
                    let emp = GroupEmployee(groupEmployeeID: "", employeeID: data, employeeName: tagPeoplesName[index])
                    arrDataOfEmp.append(emp)
                }
              
                let newgrp = Group(id: groupResponseModel?.id ?? "", name: stName, createdAt: "", updatedAt: "", createdBy: "", createdByName: "", employees: arrDataOfEmp)
                viewGrpData.delegate?.setUpdateOfGroup(dataOfGrp: newgrp, selectedIndex: viewGrpData.selectedGroupIndex ?? 0, isUpdate: true)
            }
        } failureHandler: { error in
            print(error)
        }
        DispatchQueue.main.async {
            print("This is run on the main queue, after the previous code in outer block")
        }
    }
}
