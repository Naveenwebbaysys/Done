//
//  ViewStatusViewController.swift
//  Done
//
//  Created by Mac on 09/06/23.
//

import UIKit

class ViewStatusViewController: UIViewController {

    var postID = ""
    var notes = ""
    var dueDate = ""
    var statusModelArray = [PostStatus]()
    @IBOutlet weak var statusTB : UITableView!
    @IBOutlet weak var descLbl : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.statusTB.delegate = self
        self.statusTB.dataSource = self
        
        self.statusTB.register(UINib(nibName: "ViewStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "ViewStatusTableViewCell")
        
        self.descLbl.text = notes
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
            
            self.statusModelArray.append(contentsOf: a)
            self.statusModelArray.append(contentsOf: b)
            
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
        
        cell.nameLbl.text = self.statusModelArray[indexPath.row].employeeName
        cell.statusLbl.text = self.statusModelArray[indexPath.row].status
        cell.statusLbl.textColor = self.statusModelArray[indexPath.row].status == "still working" ? .red : .green
        cell.dateLbl.text = dueDate
        cell.commentsBtn.tag = indexPath.row
        cell.commentsBtn.addTarget(self, action: #selector(commentBtnAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
        
    }
    
}


extension ViewStatusViewController {
    
    @objc func commentBtnAction(_ sender : UIButton)
    {
        let commentsVC = storyboard?.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsVC.desc = self.descLbl.text ?? ""
        commentsVC.empIDID = self.statusModelArray[sender.tag].orderAssigneeEmployeeID!
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
}
