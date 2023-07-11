//
//  TagsUsersViewController.swift
//  Done
//
//  Created by Mac on 10/06/23.
//

import UIKit
import iOSDropDown

protocol MyDataSendingDelegateProtocol {
    func sendDataToFirstViewController(tagsID: [String], tagname:[String], groupId : Int, groupName : String)
}

class TagsUsersViewController: UIViewController {
    
    var tagPeoples1 =  [String]()
    var tags1       =  [String]()
    var tagIDSArray =  [String]()
    var groupIDAry     =  [String]()
    var delegate: MyDataSendingDelegateProtocol? = nil
    var isSerching  = false
    var isDropSownVisible   = 0
    var groupId = 0
    var groupname = String()
    var tagsUsersArray      =  [TagUsers]()
    var recentUsersArray    =  [TagUsers]()
    var backUpUsersArray    =  [TagUsers]()
    var filteredTagsUsersArray  =  [TagUsers]()
    var groupsArray         =  [Groups]()
    var departmentsArry = [String]()
    
    @IBOutlet weak var tagsTableVw  : UITableView!
    @IBOutlet weak var doneBtn  : UIButton!
    @IBOutlet weak var dropdownTF : DropDown!
    @IBOutlet weak var searchTF : UITextField!
    @IBOutlet weak var bottomVW : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tagsTableVw.register(UINib(nibName: "TagUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "TagUsersTableViewCell")
        tagsTableVw.delegate = self
        tagsTableVw.dataSource = self
        self.searchTF.delegate = self
        tagsTableVw.separatorStyle = .none
        tagsTableVw.tableFooterView = UIView()
        //        mainDropDown.optionIds = option.ids
        dropdownTF.checkMarkEnabled = false
        //        dropdownTF.semanticContentAttribute = .forceRightToLeft
        dropdownTF.textColor = .black
        dropdownTF.arrowSize = 12
        dropdownTF.arrowColor = UIColor(named: "App_color")!
        dropdownTF.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.departmentsArry.append("Select Department")
        
        getTagUsersAPICall()
        if let id = UserDefaults.standard.value(forKey: UserDetails.userId)
        {
            getGroupsAPICall(withLoginId: id as! String)
        }
        
    }
    
    func getTagUsersAPICall(){
        
        APIModel.getRequest(strURL: BASEURL + GETTAGUSERS, postHeaders: headers as NSDictionary) { [self] jsonData in
            print(jsonData)
            let tagsResponseModel = try? JSONDecoder().decode(TagsResponseModel.self, from: jsonData as! Data)
            if tagsResponseModel?.data != nil
            {
                self.tagsUsersArray = (tagsResponseModel?.data)!
                self.backUpUsersArray = (tagsResponseModel?.data)!
                
                recentTagUsersAPICall()
                
                for (index, _) in self.tagsUsersArray.enumerated() {
                    if !self.departmentsArry.contains(self.tagsUsersArray[index].departmentName!){
                        self.departmentsArry.append(self.tagsUsersArray[index].departmentName!)
                    }
                    if self.tagIDSArray.contains(self.tagsUsersArray[index].id!){
                        self.tagsUsersArray[index].isSelected = true
                    }
                    else
                    {
                        self.tagsUsersArray[index].isSelected = false
                    }
                }
                //                self.tagsTableVw.reloadData()
                dropdownTF.optionArray = self.departmentsArry
            }
            else
            {
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
                
                print(self.tagsUsersArray.count)
                print(self.recentUsersArray.count)
                self.tagsUsersArray = tagsUsersArray.filter { item in
                    !recentUsersArray.contains { $0.id == item.id }
                }
                print(self.tagsUsersArray.count)
                print(self.recentUsersArray.count)
            }
            else
            {
                print("Tag users data empty")
            }
            self.tagsTableVw.reloadData()
        } failure: { error in
            print(error)
        }
    }
    
    func getGroupsAPICall(withLoginId : String)
    {
        APIModel.getRequest(strURL: BASEURL + GETGROUPSAPI, postHeaders: headers as NSDictionary) { jsonResult in
            let groupsResponse = try? JSONDecoder().decode(GetGroupsResponseModel.self, from: jsonResult as! Data)
            if groupsResponse?.data?.groups != nil
            {
                self.groupsArray = (groupsResponse?.data?.groups)!
                
                for i in 0..<self.groupsArray.count
                {
                    self.groupsArray[i].isGroupSelected = false
                    
                    if "\(self.groupId)" == self.groupsArray[i].id
                    {
                        self.groupsArray[i].isGroupSelected = true
                    }
                    else{
                        self.groupsArray[i].isGroupSelected = false
                    }
                }          
            }
            else
            {
                print("No Groups found")
            }
            
        } failure: { error in
            print(error)
        }
    }
}

extension TagsUsersViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0
        {
            return self.groupsArray.count != 0 ?  " Groups" : ""
        }
        else if section == 1
        {
            return self.recentUsersArray.count != 0 ? " Recent" : ""
        }
        else
        {
            return " All"
        }
        
        //        return section == 0 ? (self.recentUsersArray.count != 0 ? " Recent" : "" ): " All"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //        view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(named: "App_color")
        header.textLabel?.font =  UIFont.boldSystemFont(ofSize: 18.0)
        header.textLabel?.headerWidth = tagsTableVw.frame.width
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0
        {
            return  self.groupsArray.count
        }
        else if section == 1
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
            cell.taguserNameLbl.text = self.groupsArray[indexPath.row].name ?? ""
            cell.seletionBtn.tag = indexPath.row
            cell.deptLbl.text = ""
            //            cell.seletionBtn.setImage(UIImage(named: "uncheck"), for: .normal)
            cell.seletionBtn.addTarget(self, action: #selector(selectuserAction), for: .touchUpInside)
            if self.groupsArray[indexPath.row].isGroupSelected == false
            {
                cell.seletionBtn.setImage(UIImage(named: "uncheck"), for: .normal)
            }
            else
            {
                cell.seletionBtn.setImage(UIImage(named: "ic_check"), for: .normal)
                
            }
            
            //            let id = self.groupsArray[indexPath.row].id!
            //            if self.groupIDAry.contains(id){
            //                cell.seletionBtn.setImage(UIImage(named: "check"), for: .normal)
            //                //                cell.seletionBtn.tintColor = UIColor(hex:"98C455")
            //            }else{
            //                cell.seletionBtn.setImage(UIImage(named: "uncheck"), for: .normal)
            //                //                cell.seletionBtn.tintColor = .darkGray
            //            }
            
        }
        
        else if indexPath.section == 1
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
                //                cell.seletionBtn.tintColor = UIColor(hex:"98C455")
            }else{
                cell.seletionBtn.setImage(UIImage(named: "uncheck"), for: .normal)
                //                cell.seletionBtn.tintColor = .darkGray
            }
        }
        else
        {
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
                
                //                cell.seletionBtn.tintColor = UIColor(hex:"98C455")
            }else{
                cell.seletionBtn.setImage(UIImage(named: "uncheck"), for: .normal)
                //                cell.seletionBtn.tintColor = .darkGray
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


extension TagsUsersViewController{
    
    @objc func selectuserAction(_ sender : UIButton){
        
        let point = sender.convert(CGPoint.zero, to: self.tagsTableVw as UIView)
        let indexPath: IndexPath! = tagsTableVw.indexPathForRow(at: point)
        print("indexPath.row is = \(indexPath.row) && indexPath.section is = \(indexPath.section)")
        
        if indexPath.section == 0
        {
            for (k, _) in self.groupsArray.enumerated() {
                if k == indexPath.row{
                    if self.groupsArray[k].isGroupSelected == true
                    {
                        self.groupsArray[k].isGroupSelected = false
                        self.groupId = 0
                        self.groupname = ""
                    }
                    else
                    {
                        self.groupsArray[k].isGroupSelected = true
                        self.groupId = Int(self.groupsArray[k].id!) ?? 0
                        self.groupname = self.groupsArray[k].name!
                    }
                }
                else
                {
                    self.groupsArray[k].isGroupSelected = false
                    //                    self.groupId = 0
                }
            }
            UIView.performWithoutAnimation {
                self.tagsTableVw.reloadSections([indexPath.section], with: .none)
            }
        }
        else
        {
            if isSerching == false
            {
                if indexPath.section == 1
                {
                    if self.tags1.contains(self.recentUsersArray[sender.tag].id!){
                        if let idx = self.tags1.firstIndex(where: { $0 == self.recentUsersArray[sender.tag].id!}) {
                            self.tagPeoples1.remove(at: idx)
                            self.tags1.remove(at: idx)
                        }
                    }
                    else{
                        self.tagPeoples1.append(self.recentUsersArray[sender.tag].firstName!)
                        self.tags1.append(self.recentUsersArray[sender.tag].id!)
                    }
                }
                else
                {
                    if self.tags1.contains(self.tagsUsersArray[sender.tag].id!){
                        if let idx = self.tags1.firstIndex(where: { $0 == self.tagsUsersArray[sender.tag].id!}) {
                            self.tagPeoples1.remove(at: idx)
                            self.tags1.remove(at: idx)
                        }
                    }
                    else{
                        self.tagPeoples1.append(self.tagsUsersArray[sender.tag].firstName!)
                        self.tags1.append(self.tagsUsersArray[sender.tag].id!)
                    }
                }
            }
            else
            {
                if indexPath.section == 1
                {
                    if self.tags1.contains(self.recentUsersArray[sender.tag].id!){
                        if let idx = self.tags1.firstIndex(where: { $0 == self.recentUsersArray[sender.tag].id!}) {
                            self.tagPeoples1.remove(at: idx)
                            self.tags1.remove(at: idx)
                        }
                    }
                    else{
                        self.tagPeoples1.append(self.recentUsersArray[sender.tag].firstName!)
                        self.tags1.append(self.recentUsersArray[sender.tag].id!)
                    }
                }
                else
                {
                    if self.tags1.contains(self.filteredTagsUsersArray[sender.tag].id!){
                        if let idx = self.tags1.firstIndex(where: { $0 == self.filteredTagsUsersArray[sender.tag].id!}) {
                            self.tagPeoples1.remove(at: idx)
                            self.tags1.remove(at: idx)
                        }
                    }
                    else{
                        self.tagPeoples1.append(self.filteredTagsUsersArray[sender.tag].firstName!)
                        self.tags1.append(self.filteredTagsUsersArray[sender.tag].id!)
                    }
                }
            }
            
            let indexPosition = IndexPath(row: indexPath.row, section: indexPath.section)
            UIView.performWithoutAnimation {
                self.tagsTableVw.reloadRows(at: [indexPosition], with: .none)
            }
        }
        print(self.groupId)
        print(self.groupname)
        print(self.tagPeoples1)
        print(self.tags1)
    }
    
    @IBAction func backBtnAction(){
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func doneBtnAction(){
        self.delegate?.sendDataToFirstViewController(tagsID: self.tags1, tagname: self.tagPeoples1,groupId: self.groupId, groupName: self.groupname)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropDownBtnAction(){
        if isDropSownVisible == 0
        {
            isDropSownVisible = 1
            self.dropdownTF.showList()
            dropdownTF.didSelect { [self] selectedText, index, id in
                self.tagsUsersArray.removeAll()
                print( "Selected String: \(selectedText) \n index: \(index) \n Id: \(id)")
                if index == 0 {
                    self.tagsUsersArray = self.backUpUsersArray
                }
                else
                {
                    self.tagsUsersArray = self.backUpUsersArray.filter { $0.departmentName == selectedText }
                }
                print(self.tagsUsersArray.count)
                self.tagsTableVw.reloadData()
                self.dropdownTF.hideList()
                isDropSownVisible = 0
            }
        }
        else
        {
            isDropSownVisible = 0
            self.dropdownTF.hideList()
        }
    }
}



extension TagsUsersViewController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        tagPeoples1 =  [String]()
        //        tags1 =  [String]()
        
        let updatedString : String = ((textField.text as NSString?)?.replacingCharacters(in: range, with: string))!
        
        print(tagsUsersArray.count)
        let fff = self.tagsUsersArray.filter({
            $0.lastName! == updatedString
        })
        
        let filteredArr = tagsUsersArray.filter({$0.firstName!.localizedCaseInsensitiveContains(updatedString)})
        if updatedString.count > 0
        {
            isSerching = true
        }
        else
        {
            isSerching = false
        }
        print(filteredArr)
        print(filteredArr.count)
        self.filteredTagsUsersArray = filteredArr
        for (index, _) in self.filteredTagsUsersArray.enumerated() {
            
            if self.tags1.contains(self.filteredTagsUsersArray[index].id!){
                self.filteredTagsUsersArray[index].isSelected = true
            }
            else
            {
                self.filteredTagsUsersArray[index].isSelected = false
            }
        }
        self.tagsTableVw.reloadSections([2], with: .none)
        return true
    }
}
