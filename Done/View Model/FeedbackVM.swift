//
//  FeedbackVM.swift
//  Done
//
//  Created by Sagar on 13/07/23.
//

import UIKit
import KRProgressHUD

class FeedbackVM: NSObject {
    
    static let shared = FeedbackVM()
    var controller : UIViewController?
    
    func addTaskReview(postID:Int,employeeID:Int,taskStatus:String,review:String,rating:String){
        KRProgressHUD.show()
        let postparams = ReviewDoneRequestModel(postID: postID, employeeID: employeeID, taskStatus: taskStatus, review: review, rating: rating, orderAssigneeID: postID)
        print(postparams)
        APIModel.putRequest(strURL: BASEURL + UPDATEPOSTASDONE as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { result in
            KRProgressHUD.dismiss()
            self.controller?.setRootVC()
            print("Task review",String(data: result as! Data, encoding: .utf8))
        } failureHandler: { error in
            KRProgressHUD.dismiss()
            self.controller?.showToast(message: error)
        }
    }
}
