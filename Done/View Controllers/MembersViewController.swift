//
//  MembersViewController.swift
//  Done
//
//  Created by Mac on 13/07/23.
//

import UIKit

class MembersViewController: UIViewController {
    
    var postID = ""
    var memberName = ""
    var memberID = 0
    var isSerching  = false
    var tagIDSArray =  [Int]()
    var filterIDSArray =  [Member]()
    @IBOutlet weak var membersTB : UITableView!
    @IBOutlet weak var searchTF : UITextField!
    var membersArray =  [Member]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        self.getMembers(withPostID: postID)
    }
    
    func setupTableView()
    {
        self.membersTB.register(UINib(nibName: "TagUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "TagUsersTableViewCell")
        membersTB.delegate = self
        membersTB.dataSource = self
    }
    
    func getMembers(withPostID : String)
    {
        APIModel.getRequest(strURL: BASEURL + GETILLDOUSERS + withPostID , postHeaders: headers as NSDictionary) { jsonData in
            
            let membersModel = try? JSONDecoder().decode(MembersModel.self, from: jsonData as! Data)
            
            self.membersArray = membersModel?.data ?? [Member]()
            
            for i in 0..<self.membersArray.count
            {
                self.membersArray[i].isSelected = false
                if "\(self.memberID)" == self.membersArray[i].id
                {
                    self.membersArray[i].isSelected = true
                }
                else{
                    self.membersArray[i].isSelected = false
                }
            }
            
            
            self.membersTB.reloadData()
        } failure: { error in
            print(error)
        }
    }
    
    @IBAction func bactBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension MembersViewController : UITableViewDelegate , UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.membersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagUsersTableViewCell", for: indexPath) as! TagUsersTableViewCell
        
        let firstName = self.membersArray[indexPath.row].firstName ?? ""
        let lastName = self.membersArray[indexPath.row].lastName ?? ""
        cell.taguserNameLbl.text = firstName + " " + lastName
        cell.seletionBtn.tag = indexPath.row
        cell.deptLbl.text = ""
        if self.membersArray[indexPath.row].isSelected == false
        {
            cell.seletionBtn.setImage(UIImage(named: "uncheck"), for: .normal)
        }
        else
        {
            cell.seletionBtn.setImage(UIImage(named: "ic_check"), for: .normal)
            
        }
        cell.seletionBtn.addTarget(self, action: #selector(selectuserAction), for: .touchUpInside)
        
        
        
        return cell
    }
}


extension MembersViewController {
    
    @objc func selectuserAction(_ sender : UIButton){
 
        for (k, _) in self.membersArray.enumerated() {
            if k == sender.tag{
                if self.membersArray[k].isSelected == true
                {
                    self.membersArray[k].isSelected = false
                    self.memberID = 0
                    self.memberName = ""
                }
                else
                {
                    self.membersArray[k].isSelected = true
                    self.memberID = Int(self.membersArray[k].id!) ?? 0
                    
                }
            }
            else
            {
                self.membersArray[k].isSelected = false
                //                    self.groupId = 0
            }
        }
        
        
        print(self.memberID)
        UIView.performWithoutAnimation {
            self.membersTB.reloadSections([0], with: .none)
        }
    }
    
    @IBAction func doneBtnAction(){
        
        if self.memberID != 0
        {
            self.tagIDSArray.append(self.memberID)
            
            let p = AddMembersModel(id: postID, tagPeoples: self.tagIDSArray)
            APIModel.patchRequest(strURL: BASEURL + UPDATEPOSTAPI as NSString, postParams: p, postHeaders: headers as NSDictionary) { result in
                print(result)
                self.navigationController?.popViewController(animated: true)
            } failureHandler: { error in
                print(error)
            }
        }
        else
        {
            self.showToast(message: "Please select Employee")
        }
    }
    
    
}


extension MembersViewController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        tagPeoples1 =  [String]()
        //        tags1 =  [String]()
        
        let updatedString : String = ((textField.text as NSString?)?.replacingCharacters(in: range, with: string))!
        
        print(membersArray.count)
        let fff = self.membersArray.filter({
            $0.lastName! == updatedString
        })
        
        let filteredArr = membersArray.filter({$0.firstName!.localizedCaseInsensitiveContains(updatedString)})
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
        self.filterIDSArray = filteredArr
        for (index, _) in self.filterIDSArray.enumerated() {
            
            if self.tagIDSArray.contains(Int(self.filterIDSArray[index].id!) ?? 0){
                self.filterIDSArray[index].isSelected = true
            }
            else
            {
                self.filterIDSArray[index].isSelected = false
            }
        }
        self.membersTB.reloadSections([2], with: .none)
        return true
    }
}
