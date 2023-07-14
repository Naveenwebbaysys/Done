//
//  TaskProofPreviewVM.swift
//  Done
//
//  Created by Sagar on 14/07/23.
//

import UIKit
import KRProgressHUD

class TaskProofPreviewVM: NSObject {

    static let shared = TaskProofPreviewVM()
    var controller : UIViewController?
    
    func updatesAPICall(postID:Int,employeeID:Int,taskStatus:String,stReason:String,createdBy:String){
        let postparams = UpdateDoneRequestModel(postID: postID, employeeID: employeeID, taskStatus: taskStatus,proofDescription: nil,proofDocument: nil, orderAssigneeID: postID)
        KRProgressHUD.show()
        APIModel.putRequest(strURL: BASEURL + UPDATEPOSTASDONE as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { result in
            KRProgressHUD.dismiss()
//            print("Reject task",String(data: result as! Data, encoding: .utf8))
            CommentsVM.shared.addCommentsAPICall(str: "", stOrderAssigneeEmployeeID: "", employeeID: "\(employeeID)", postID: "\(postID)", stComment: stReason, commentType: "text", taskId: createdBy)
            self.controller?.setRootVC()
        } failureHandler: { error in
            
            print(error)
        }
    }
}
