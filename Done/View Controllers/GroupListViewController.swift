//
//  GroupListViewController.swift
//  Done
//
//  Created by Sagar on 10/07/23.
//

import UIKit

class GroupListViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var tableviewGroupList: UITableView!
    
    //MARK: - Variable
    var arrGroups: [Group] = [Group]()
    var currentPage:Int = 1
    var isLastPage: Bool = false
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        GroupListVM.shared.controller = self
        self.tableviewGroupList.register(UINib(nibName: "GroupListTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupListTableViewCell")
        GroupListVM.shared.getGroupList(pageNO: currentPage)
    }
    
    //MARK: - UIButton Actions
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCreateGroupsAction(_ sender: UIButton) {
        let groupCreateVC = storyboard?.instantiateViewController(withIdentifier: "GroupCreateViewController") as! GroupCreateViewController
        groupCreateVC.delegate = self
        self.navigationController?.pushViewController(groupCreateVC, animated: true)
    }
    
    
}

extension GroupListViewController:  UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListTableViewCell", for: indexPath) as! GroupListTableViewCell
        let data = arrGroups[indexPath.row]
        cell.lblGroupName.text = data.name ?? ""
        var arrUserName: [String] = [String]()
        for empData in (data.employees ?? [GroupEmployee]()){
            arrUserName.append(empData.employeeName ?? "")
        }
        cell.lblGroupMemberList.text = arrUserName.joined(separator: ", ")
        if indexPath.row == self.arrGroups.count - 1 {
            if !isLastPage{
                print("Coniddtion done.",indexPath.row)
                currentPage += 1
                GroupListVM.shared.getGroupList(pageNO: currentPage)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupCreateVC = storyboard?.instantiateViewController(withIdentifier: "GroupCreateViewController") as! GroupCreateViewController
        groupCreateVC.isEditGroup = true
        groupCreateVC.selectedGroup = arrGroups[indexPath.row]
        groupCreateVC.selectedGroupIndex = indexPath.row
        groupCreateVC.delegate = self
        self.navigationController?.pushViewController(groupCreateVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension GroupListViewController : delegateGroupCreateVC{
    func setUpdateOfGroup(dataOfGrp: Group, selectedIndex: Int, isUpdate: Bool) {
        if isUpdate{
            self.arrGroups[selectedIndex] = dataOfGrp
            self.tableviewGroupList.reloadData()
        }else{
            self.arrGroups.append(dataOfGrp)
            self.tableviewGroupList.reloadData()
        }
        
    }
    
    
}
