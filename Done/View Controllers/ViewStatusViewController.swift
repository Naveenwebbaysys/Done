//
//  ViewStatusViewController.swift
//  Done
//
//  Created by Mac on 09/06/23.
//

import UIKit
import Kingfisher

class ViewStatusViewController: UIViewController {
    
    var postID = ""
    var notes = ""
    var dueDate = ""
    var statusModelArray = [PostStatus]()
    var reelsModelArray = [Post]()
    var index = 0
    var task = ""
    var isFromEdit = Bool()
    @IBOutlet weak var statusTB : UITableView!
    @IBOutlet weak var descLbl : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusTB.delegate = self
        self.statusTB.dataSource = self
        self.statusTB.register(UINib(nibName: "ViewStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "ViewStatusTableViewCell")
        self.descLbl.text = notes
        self.statusTB.rowHeight = UITableView.automaticDimension
        self.statusTB.estimatedRowHeight = 110
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusModelArray = [PostStatus]()
        statusAPICall(withPostID: postID)
    }
    
    func statusAPICall(withPostID : String)
    {
        let statusURL = BASEURL + VIEWSTATUS + withPostID
        APIModel.getRequest(strURL: statusURL, postHeaders: headers as NSDictionary) { jsonData in
            
            let viewStatusResponseModel = try? JSONDecoder().decode(ViewStatusResponseModel.self, from: jsonData as! Data)
            let a = (viewStatusResponseModel?.data?.stillWorkingPosts)!
            let b = (viewStatusResponseModel?.data?.donePosts)!
            let c = (viewStatusResponseModel?.data?.approved)!
            self.statusModelArray.append(contentsOf: a)
            self.statusModelArray.append(contentsOf: b)
            self.statusModelArray.append(contentsOf: c)
            
            for (index, _) in self.statusModelArray.enumerated() {
                
                if self.statusModelArray[index].status == "approved"
                {
                    self.statusModelArray[index].isApprovedCheked = true
                }
                else
                {
                    self.statusModelArray[index].isApprovedCheked = false
                }
                
                if self.statusModelArray[index].status == "done_success"
                {
                    self.statusModelArray[index].isdoneCheked = true
                }
                else
                {
                    self.statusModelArray[index].isdoneCheked = false
                }
            }
            
            
            print(self.statusModelArray.count)
            self.statusTB.reloadData()
        } failure: { error in
            print(error)
        }
    }
    
    @IBAction func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
}



extension ViewStatusViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.statusModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewStatusTableViewCell", for: indexPath) as! ViewStatusTableViewCell
        
        cell.nameLbl.text = self.statusModelArray[indexPath.row].employeeName ?? ""
        cell.statusLbl.text = self.statusModelArray[indexPath.row].status
       
        
        // == "still_working" ? "Still working" : "Done success"
        //        cell.statusLbl.textColor = self.statusModelArray[indexPath.row].status == "still_working" ? .red : .green
        cell.lastMsgLbl.text = self.statusModelArray[indexPath.row].lastmessage ?? ""
        cell.commentCountLbl.text = self.statusModelArray[indexPath.row].commentscount ?? "0"
        cell.dateLbl.text = dueDate
        cell.commentsBtn.tag = indexPath.row
        cell.commentsBtn.addTarget(self, action: #selector(commentBtnAction), for: .touchUpInside)
        cell.markBtn.tag = indexPath.row
        cell.markBtn.addTarget(self, action: #selector(markBtnAction), for: .touchUpInside)
        cell.approvedBtn.tag = indexPath.row
        cell.approvedBtn.addTarget(self, action: #selector(approvedBtnAction), for: .touchUpInside)
        
        let lastMsg = self.statusModelArray[indexPath.row].lastmessage ?? ""
        if lastMsg.contains("--") == true
        {
            let ar = split(content: self.statusModelArray[indexPath.row].lastmessage!)
            cell.lastMsgLbl.text = ar[1] as? String
            let url = URL(string: ar[0] as! String)
            DispatchQueue.main.async {
//                cell.mediaImgVW.kf.setImage(with: url)
            }
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    cell.mediaImgVW.image = UIImage(data: data!)
                }
            }
        }
        else
        {
            cell.lastMsgLbl.text = self.statusModelArray[indexPath.row].lastmessage ?? ""
        }
        
        if self.statusModelArray[indexPath.row].isApprovedCheked == true
        {
            cell.approvedBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
        else
        {
            cell.approvedBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        if self.statusModelArray[indexPath.row].isdoneCheked == true
        {
            cell.markBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
        else
        {
            cell.markBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension ViewStatusViewController {
    
    @objc func commentBtnAction(_ sender : UIButton)
    {
        let commentsVC = storyboard?.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsVC.postid = postID
        commentsVC.desc = self.descLbl.text ?? ""
        commentsVC.postPeopleSelected = reelsModelArray[index].tagPeoples![sender.tag]
        commentsVC.assignEmpID = self.statusModelArray[sender.tag].orderAssigneeEmployeeID!
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    @IBAction func editBtnAction() {
//        navToPostVc()
        
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        postVC.reelsModelArray = self.reelsModelArray
        postVC.index = index
        postVC.isFromEdit = true
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
    @objc func markBtnAction(_ sender : UIButton) {
        if self.statusModelArray[sender.tag].isdoneCheked == true
        {
            task = "still_working"
            self.statusModelArray[sender.tag].isdoneCheked = false
        }
        else
        {
            task = "done_success"
            self.statusModelArray[sender.tag].isdoneCheked = true
        }
        self.statusModelArray[sender.tag].isApprovedCheked = false
        updatesAPICall(withTask: task, index: sender.tag)
    }
    
    @objc func approvedBtnAction(_ sender : UIButton) {
        if self.statusModelArray[sender.tag].isApprovedCheked == true
        {
            task = "still_working"
            self.statusModelArray[sender.tag].isApprovedCheked = false
        }
        else
        {
            task = "approved"
            self.statusModelArray[sender.tag].isApprovedCheked = true
        }
        self.statusModelArray[sender.tag].isdoneCheked = false
        updatesAPICall(withTask: task, index: sender.tag)
    }
    
    func updatesAPICall(withTask: String, index : Int)
    {
        let postparams = UpdateDoneRequestModel(postID: Int(self.statusModelArray[index].postID!), employeeID: Int(self.statusModelArray[index].employeeID!), taskStatus: withTask)
        APIModel.putRequest(strURL: BASEURL + UPDATEPOSTASDONE as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { result in

            let indexPathRow:Int = index
            let indexPosition = IndexPath(row: indexPathRow, section: 0)
            self.statusTB.reloadRows(at: [indexPosition], with: .none)
            
        } failureHandler: { error in
            
            print(error)
        }
    }
    func split(content : String) -> NSArray
    {
        var ar = [String]()
        if content.contains("--") == true {
            ar = content.components(separatedBy: "--")
            let media: String = ar[0]
            let text: String = ar[1]
            print(media)
            print(text)
        }
        return ar as NSArray
    }
}

