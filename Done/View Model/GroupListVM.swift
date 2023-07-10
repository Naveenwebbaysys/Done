//
//  GroupListVM.swift
//  Done
//
//  Created by Sagar on 10/07/23.
//

import UIKit

class GroupListVM: NSObject {

    static let shared = GroupListVM()
    var controller : UIViewController?
    
    func getGroupList(pageNO:Int){
        APIModel.getRequest(strURL: BASEURL + GROUPSAPI + "?page_no=\(pageNO)", postHeaders:  headers as NSDictionary) { result in
            let groupListResponseModel = try? JSONDecoder().decode(GroupListDetails.self, from: result as! Data)
            for data in (groupListResponseModel?.data?.groups ?? [Group]()){
                if let viewGrpData = self.controller as? GroupListViewController{
                    viewGrpData.arrGroups.append(data)
                }
            }
            
            if let viewGrpData = self.controller as? GroupListViewController{
                viewGrpData.isLastPage = (groupListResponseModel?.data?.groups ?? [Group]()).count == 10 ? false : true
                print("last data==",viewGrpData.isLastPage)
                viewGrpData.tableviewGroupList.reloadData()
            }
        } failure: { error in
            print(error)
        }
    }
}
