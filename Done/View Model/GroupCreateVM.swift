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
    
    func addGroupsAPICall(employeesID : [String],stName:String){
        let postparams = CreateGroupsRequestModel(employees: employeesID, name: stName)
                print("Request parameter==",postparams)
        //            print("This is run on the background queue")
        KRProgressHUD.show()
        APIModel.backGroundPostRequest(strURL: BASEURL + GROUPSAPI as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { jsonResult in
            KRProgressHUD.dismiss()
            self.controller?.navigationController?.popViewController(animated: true)
            print("background post comment==\(String(data: jsonResult as! Data, encoding: .utf8))")
            //            self.controller?.navigationController?.popViewController(animated: true)
        } failureHandler: { error in
            print(error)
        }
        DispatchQueue.main.async {
            print("This is run on the main queue, after the previous code in outer block")
        }
    }
}
