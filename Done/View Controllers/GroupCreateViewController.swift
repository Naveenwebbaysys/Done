//
//  GroupCreateViewController.swift
//  Done
//
//  Created by Sagar on 08/07/23.
//

import UIKit
import iOSDropDown

protocol delegateGroupCreateVC{
    func setUpdateOfGroup(dataOfGrp:Group,selectedIndex:Int,isUpdate:Bool)
}

class GroupCreateViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var txtSelection: DropDown!
    @IBOutlet weak var txtSearchList: UITextField!
    @IBOutlet weak var tabelviewList: UITableView!
    
    //MARK: - Varible
    var tagsUsersArray  =  [TagUsers]()
    var recentUsersArray  =  [TagUsers]()
    var backUpUsersArray  =  [TagUsers]()
    var filteredTagsUsersArray  =  [TagUsers]()
    var isSerching = false
    var tags1 =  [String]()
    var tagPeoples1 =  [String]()
    var departmentsArry = [String]()
    var tagIDSArray =  [String]()
    var isDropSownVisible = 0
    
    var isEditGroup: Bool?
    var selectedGroup: Group?
    var delegate: delegateGroupCreateVC?
    var selectedGroupIndex:Int?
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        GroupCreateVM.shared.controller = self
        self.tabelviewList.register(UINib(nibName: "TagUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "TagUsersTableViewCell")
        self.txtSearchList.delegate = self
        tabelviewList.separatorStyle = .none
        tabelviewList.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        getTagUsersAPICall()
        if (self.isEditGroup ?? false){
            self.txtGroupName.text = selectedGroup?.name ?? ""
            for empData in (selectedGroup?.employees ?? [GroupEmployee]()){
                tags1.append(empData.employeeID ?? "")
                tagPeoples1.append(empData.employeeName ?? "")
            }
        }
    }
    
    //MARK: - Other methods
    func getTagUsersAPICall(){
        APIModel.getRequest(strURL: BASEURL + GETTAGUSERS, postHeaders: headers as NSDictionary) { [self] jsonData in
            print(jsonData)
            let tagsResponseModel = try? JSONDecoder().decode(TagsResponseModel.self, from: jsonData as! Data)
            if tagsResponseModel?.data != nil{
                self.tagsUsersArray = (tagsResponseModel?.data)!
                self.backUpUsersArray = (tagsResponseModel?.data)!
                recentTagUsersAPICall()
                for (index, _) in self.tagsUsersArray.enumerated() {
                    if !self.departmentsArry.contains(self.tagsUsersArray[index].departmentName!){
                        self.departmentsArry.append(self.tagsUsersArray[index].departmentName!)
                    }
                    if self.tagIDSArray.contains(self.tagsUsersArray[index].id!){
                        self.tagsUsersArray[index].isSelected = true
                    }else{
                        self.tagsUsersArray[index].isSelected = false
                    }
                }
                txtSelection.optionArray = self.departmentsArry
            }else{
                print("Tag users data empty")
            }
        } failure: { error in
            print(error)
        }
    }
    
    func recentTagUsersAPICall(){
        APIModel.getRequest(strURL: BASEURL + GETTAGUSERS + "?recent=1", postHeaders: headers as NSDictionary) { [self] jsonData in
            print(jsonData)
            let tagsResponseModel = try? JSONDecoder().decode(TagsResponseModel.self, from: jsonData as! Data)
            if tagsResponseModel?.data != nil
            {
                self.recentUsersArray = (tagsResponseModel?.data)!
                self.tagsUsersArray = tagsUsersArray.filter { item in
                    !recentUsersArray.contains { $0.id == item.id }
                }
            }else{
                print("Tag users data empty")
            }
            self.tabelviewList.reloadData()
        } failure: { error in
            print(error)
        }
    }

    
    //MARK: - UIButton Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSelectionMenuAction(_ sender: UIButton) {
        if isDropSownVisible == 0{
            isDropSownVisible = 1
            self.txtSelection.showList()
            txtSelection.didSelect { [self] selectedText, index, id in
                self.tagsUsersArray.removeAll()
//                print( "Selected String: \(selectedText) \n index: \(index) \n Id: \(id)")
                if index == 0 {
                    self.tagsUsersArray = self.backUpUsersArray
                }else{
                    self.tagsUsersArray = self.backUpUsersArray.filter { $0.departmentName == selectedText }
                }
                print(self.tagsUsersArray.count)
                self.tabelviewList.reloadData()
                self.txtSelection.hideList()
                isDropSownVisible = 0
            }
        } else{
            isDropSownVisible = 0
            self.txtSelection.hideList()
        }
        
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
        if (txtGroupName.text ?? "").isEmpty{
            showToast(message: "Please enter group name")
            return
        }
        
        if tagPeoples1.count == 0{
            showToast(message: "Please select tag people")
            return
        }
        
        if (self.isEditGroup ?? false){
            GroupCreateVM.shared.editGroupsAPICall(employeesID: tags1, stName: txtGroupName.text ?? "", id: Int(selectedGroup?.id ?? "0")!,tagPeoplesName: tagPeoples1)
        }else{
            GroupCreateVM.shared.addGroupsAPICall(employeesID: tags1, stName: txtGroupName.text ?? "",tagPeoplesName: tagPeoples1)
        }
        
    }
    
    @IBAction func btnSearchCloseAction(_ sender: UIButton) {
        isSerching = false
        self.txtSearchList.text = ""
        self.tabelviewList.reloadData()
    }
    
    @objc func selectuserAction(_ sender : UIButton){
        
        let point = sender.convert(CGPoint.zero, to: self.tabelviewList as UIView)
        let indexPath: IndexPath! = tabelviewList.indexPathForRow(at: point)
        print("indexPath.row is = \(indexPath.row) && indexPath.section is = \(indexPath.section)")
        
        if isSerching == false{
            if indexPath.section == 0{
                if self.tags1.contains(self.recentUsersArray[sender.tag].id!){
                    if let idx = self.tags1.firstIndex(where: { $0 == self.recentUsersArray[sender.tag].id!}) {
                        self.tagPeoples1.remove(at: idx)
                        self.tags1.remove(at: idx)
                    }
                }
                else{
                    self.tagPeoples1.append(self.recentUsersArray[sender.tag].firstName! + " " + self.recentUsersArray[sender.tag].lastName!)
                    self.tags1.append(self.recentUsersArray[sender.tag].id!)
                }
            }else{
                if self.tags1.contains(self.tagsUsersArray[sender.tag].id!){
                    if let idx = self.tags1.firstIndex(where: { $0 == self.tagsUsersArray[sender.tag].id!}) {
                        self.tagPeoples1.remove(at: idx)
                        self.tags1.remove(at: idx)
                    }
                }
                else{
                    self.tagPeoples1.append(self.tagsUsersArray[sender.tag].firstName! + " " + self.tagsUsersArray[sender.tag].lastName!)
                    self.tags1.append(self.tagsUsersArray[sender.tag].id!)
                }
            }
        } else{
            if indexPath.section == 0{
                if self.tags1.contains(self.recentUsersArray[sender.tag].id!){
                    if let idx = self.tags1.firstIndex(where: { $0 == self.recentUsersArray[sender.tag].id!}) {
                        self.tagPeoples1.remove(at: idx)
                        self.tags1.remove(at: idx)
                    }
                }else{
                    self.tagPeoples1.append(self.recentUsersArray[sender.tag].firstName! + " " + self.recentUsersArray[sender.tag].lastName!)
                    self.tags1.append(self.recentUsersArray[sender.tag].id!)
                }
            }else{
                if self.tags1.contains(self.filteredTagsUsersArray[sender.tag].id!){
                    if let idx = self.tags1.firstIndex(where: { $0 == self.filteredTagsUsersArray[sender.tag].id!}) {
                        self.tagPeoples1.remove(at: idx)
                        self.tags1.remove(at: idx)
                    }
                }
                else{
                    self.tagPeoples1.append(self.filteredTagsUsersArray[sender.tag].firstName! + " " + self.filteredTagsUsersArray[sender.tag].lastName!)
                    self.tags1.append(self.filteredTagsUsersArray[sender.tag].id!)
                }
            }
        }
        
        let indexPosition = IndexPath(row: indexPath.row, section: indexPath.section)
        self.tabelviewList.reloadRows(at: [indexPosition], with: .none)
        
    }
}

extension GroupCreateViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return section == 0 ? (self.recentUsersArray.count != 0 ? " Recent" : "" ): " All"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //        view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(named: "App_color")
        header.textLabel?.font =  UIFont.boldSystemFont(ofSize: 18.0)
        header.textLabel?.headerWidth = tabelviewList.frame.width
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return  self.recentUsersArray.count
        }
        else
        {
            return isSerching == false ? self.tagsUsersArray.count : self.filteredTagsUsersArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagUsersTableViewCell", for: indexPath) as! TagUsersTableViewCell
        if indexPath.section == 0
        {
            let firstName = self.recentUsersArray[indexPath.row].firstName ?? ""
            let lastName = self.recentUsersArray[indexPath.row].lastName ?? ""
            
            let deptName = self.recentUsersArray[indexPath.row].departmentName ?? ""
            
            cell.taguserNameLbl.text = firstName + " " + lastName
            //        cell.deptLbl.text = self.tagsUsersArray[indexPath.row].departmentName ?? ""
            cell.deptLbl.text = deptName
            cell.seletionBtn.addTarget(self, action: #selector(selectuserAction), for: .touchUpInside)
            cell.seletionBtn.tag = indexPath.row
            
            let id = self.recentUsersArray[indexPath.row].id!
            if self.tags1.contains(id){
                cell.seletionBtn.setImage(UIImage(named: "ic_check"), for: .normal)
            }else{
                cell.seletionBtn.setImage(UIImage(named: "uncheck"), for: .normal)
            }
        }else{
            let firstName = isSerching == false ? (self.tagsUsersArray[indexPath.row].firstName ?? "") : (self.filteredTagsUsersArray[indexPath.row].firstName ?? "")
            let lastName = isSerching == false ?  (self.tagsUsersArray[indexPath.row].lastName ?? "") : (self.filteredTagsUsersArray[indexPath.row].lastName ?? "")
            
            let deptName = isSerching == false ? (self.tagsUsersArray[indexPath.row].departmentName ?? "") : (self.filteredTagsUsersArray[indexPath.row].departmentName ?? "")
            
            cell.taguserNameLbl.text = firstName + " " + lastName
            //        cell.deptLbl.text = self.tagsUsersArray[indexPath.row].departmentName ?? ""
            cell.deptLbl.text = deptName
            cell.seletionBtn.addTarget(self, action: #selector(selectuserAction), for: .touchUpInside)
            cell.seletionBtn.tag = indexPath.row
            
            let id = isSerching == false ? self.tagsUsersArray[indexPath.row].id! : self.filteredTagsUsersArray[indexPath.row].id!
            if self.tags1.contains(id){
                cell.seletionBtn.setImage(UIImage(named: "ic_check"), for: .normal)
            }else{
                cell.seletionBtn.setImage(UIImage(named: "uncheck"), for: .normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

extension GroupCreateViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString : String = ((textField.text as NSString?)?.replacingCharacters(in: range, with: string))!
        
        let filteredArr = tagsUsersArray.filter({$0.firstName!.localizedCaseInsensitiveContains(updatedString)})
        if updatedString.count > 0{
            isSerching = true
        }else{
            isSerching = false
        }
     
        self.filteredTagsUsersArray = filteredArr
        for (index, _) in self.filteredTagsUsersArray.enumerated() {
            if self.tags1.contains(self.filteredTagsUsersArray[index].id!){
                self.filteredTagsUsersArray[index].isSelected = true
            }else{
                self.filteredTagsUsersArray[index].isSelected = false
            }
        }
        self.tabelviewList.reloadSections([1], with: .none)
        return true
    }
}
