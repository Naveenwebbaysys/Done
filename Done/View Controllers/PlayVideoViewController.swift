//
//  PlayVideoViewController.swift
//  Done
//
//  Created by Mac on 30/06/23.
//

import UIKit
import AVFoundation

protocol indexProtocol {
    func indexID(i: Int)
}
class PlayVideoViewController: UIViewController,taskProofviewDelegate {
    
    var selectedIndex = Int()
    var delegate: indexProtocol? = nil
    
    @IBOutlet weak var palyVideoTV : UITableView!
    var reelModelArray = [Post]()
    var userID = ""
    var assigneeComments = [AssigneeComment]()
    var totalComments =  [TotalComment]()
    var isSuccess = false
    var idFromDone = Bool()
    var menuIndex = Int()
    var noofemployeestagged = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        self.palyVideoTV.register(UINib(nibName: "ReelsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReelsTableViewCell")
        palyVideoTV.delegate = self
        palyVideoTV.dataSource = self
        userID = UserDefaults.standard.value(forKey: UserDetails.userId) as! String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isSuccess = false
//        toalCommentsCount(withAssinID: self.reelModelArray[0].id ?? "")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        for cell in palyVideoTV.visibleCells {
            print(":::: viewDidDisappear ::::")
            (cell as! ReelsTableViewCell).avPlayer?.seek(to: CMTime.zero)
            (cell as! ReelsTableViewCell).stopPlayback()
        }
    }
    
    func toalCommentsCount (withAssinID : String)
    {
        print(BASEURL + TOTALCOMMENTCOUNT + withAssinID)
        APIModel.optionsRequest(strURL: BASEURL + TOTALCOMMENTCOUNT + withAssinID, postHeaders: headers as NSDictionary) { jsonData in
            
            let totalCommentCount = try? JSONDecoder().decode(TotalCommentCountModel.self, from: jsonData as! Data)

            self.assigneeComments = (totalCommentCount?.assigneeComments)!
            self.totalComments = (totalCommentCount?.totalComments)!
            self.palyVideoTV.reloadData()
        } failure: { error in
            
        }

    }
    
    @IBAction func backBtnAction()
    {
        self.delegate?.indexID(i: selectedIndex)
        self.navigationController?.popViewController(animated: true)
    }
    
    func taskProofDone(index: Int) {
        self.isSuccess = true
//            self.reelsModelArray[index].
        let indexPathRow:Int = index
        let indexPosition = IndexPath(row: indexPathRow, section: 0)
        self.palyVideoTV.reloadRows(at: [indexPosition], with: .none)
    }
}

extension PlayVideoViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reelModelArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Reelcell = self.palyVideoTV.dequeueReusableCell(withIdentifier: "ReelsTableViewCell") as! ReelsTableViewCell

        Reelcell.userNameLbl.text = self.reelModelArray[indexPath.row].assigneeName
        Reelcell.marqueeLabel.text = self.reelModelArray[indexPath.row].notes
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd"
        let duedate = self.reelModelArray[indexPath.row].commissionNoOfDays1!
        let yourDate = formatter.date(from: duedate)
        formatter.dateFormat = "MMM d, yyyy"
        var days = 0
        if yourDate != nil{
            let myStringDate = formatter.string(from: yourDate!)
            days = count(expDate: myStringDate)
            Reelcell.dateLbl.text = "Expires in " + "\(days)" + " days " + myStringDate
        }
       
        let videoURL = URL(string: self.reelModelArray[indexPath.row].videoURL!)
        if videoURL !=  nil{
            Reelcell.videoPlayerItem = AVPlayerItem.init(url: videoURL!)
            let playerLayer = AVPlayerLayer(player: Reelcell.avPlayer)
            playerLayer.frame = self.view.bounds
            Reelcell.playerView.layer.addSublayer(playerLayer)
            Reelcell.avPlayer?.play()
        }
        if idFromDone == true
        {
            Reelcell.dontBtnWidth.constant = 0
        }
        else
        {
            Reelcell.dontBtnWidth.constant = 100
        }
        
        if userID == self.reelModelArray[indexPath.row].createdBy
        {
            Reelcell.dontBtnWidth.constant = 0
            Reelcell.editBtn.isHidden = false
            Reelcell.doneBtn.setTitle("View Status", for: .normal)
            if self.totalComments.count > 0
            {
                Reelcell.countLbl.text = self.totalComments[0].totalCommentsCount
            }
            else
            {
                Reelcell.countLbl.text = "0"
            }
            
            Reelcell.editHeight.constant = 28
        }
        else
        {
            Reelcell.editHeight.constant = 0
            Reelcell.dontBtnWidth.constant = 100
            Reelcell.editBtn.isHidden = true
            if  isSuccess == true
            {
                Reelcell.doneBtn.setTitle("Success", for: .normal)
            }
            else
            {
                Reelcell.doneBtn.setTitle("Done?", for: .normal)
            }
          
            if self.assigneeComments.count >  0 {
                var comment  : Int = 0
                for (index, _) in self.assigneeComments.enumerated() {
                    let a = Int(self.assigneeComments[index].assigneecomments!)
                    comment += a!
                }
                Reelcell.countLbl.text = "\(comment)"
            }
            else
            {
                Reelcell.countLbl.text = "0"
//                Reelcell.countLbl.text = self.reelModelArray[indexPath.row].tagPeoples?[0].comments?[0].comment
            }
        }
        
        
        if selectedIndex == 0
        {
            if self.reelModelArray[indexPath.row].noofemployeestagged  == "0" {
                Reelcell.dontBtnWidth.constant = 100
                Reelcell.doneBtn.setTitle("I Will Do", for: .normal)
            }
            else
            {
                Reelcell.dontBtnWidth.constant = 0
            }
        }
        
        else if selectedIndex == 1
        {
            Reelcell.dontBtnWidth.constant = 100
            Reelcell.doneBtn.setTitle("Done?", for: .normal)
        }
        else if menuIndex == 3
        {
//            Reelcell.doneBtn.setTitle("Approved", for: .normal)
            Reelcell.dontBtnWidth.constant = 100
            
            if userID == self.reelModelArray[indexPath.row].createdBy
            {
                Reelcell.doneBtn.setTitle("Approve", for: .normal)
                Reelcell.dontBtnWidth.constant = 100
            }
            else
            {
                Reelcell.doneBtn.setTitle("Success", for: .normal)
                Reelcell.dontBtnWidth.constant = 100
            }
        }

        else
        {
            Reelcell.dontBtnWidth.constant = 0
        }
     
        
        Reelcell.commissionBtn.tag = indexPath.row
        let amount = "$" + (self.reelModelArray[indexPath.row].commissionAmount ?? "0") + " - DUE IN " + "\(days)" + " DAYS "
        Reelcell.commissionBtn.setTitle(amount, for: .normal)
        Reelcell.doneBtn.tag = indexPath.row
        Reelcell.doneBtn.addTarget(self, action: #selector(statusBtnTapped(_:)), for: .touchUpInside)
        Reelcell.commentsBtn.tag = indexPath.row
        Reelcell.editBtn.tag = indexPath.row
        Reelcell.editBtn.addTarget(self, action: #selector(editBtnTapped(_:)), for: .touchUpInside)
        Reelcell.commentsBtn.addTarget(self, action: #selector(commentsBtnTapped(_:)), for: .touchUpInside)
        let arrTagPeople = (self.reelModelArray[indexPath.row].tagPeoples) ?? [TagPeople]()
        
        if !arrTagPeople.isEmpty{
            if arrTagPeople[0].comments?.isEmpty == true {
                Reelcell.countLbl.text = "0"
            }
            else
            {
                Reelcell.countLbl.text = arrTagPeople[0].comments?[0].comment
            }
        }
        else{
            Reelcell.countLbl.text = "0"
            
        }
        
//        if self.reelModelArray[indexPath.row].tagPeoples?[0].comments?.isEmpty == true {
//            Reelcell.countLbl.text = "0"
//        }
//        else
//        {
//            Reelcell.countLbl.text = self.reelModelArray[indexPath.row].tagPeoples?[0].comments?[0].comment
//        }
        
        return Reelcell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.palyVideoTV.height
    }
}

extension PlayVideoViewController {
    @objc func statusBtnTapped(_ sender: UIButton?) {
        
        print("Tapped")
        if sender?.titleLabel?.text ==  "Done?"
        {
            let taskProofView = TaskProofView.init(info: "done_success", postID: Int(self.reelModelArray[sender!.tag].id ?? "0")!, employeeID: Int(userID)!, index: sender!.tag,orderAssigneID: Int(self.reelModelArray[sender!.tag].tagPeoples?[0].orderAssigneeEmployeeID ?? "0")!, createdBy: self.reelModelArray[sender!.tag].createdBy ?? "")
            taskProofView.delegate = self
        }
        else if sender?.titleLabel?.text ==  "I Will Do"
        {
            let commentsVC = storyboard?.instantiateViewController(identifier: "CommentsViewController") as! CommentsViewController
    //        print(self.reelsModelArray[sender!.tag].tagPeoples?[0].orderAssigneeEmployeeID)
            if self.reelModelArray[sender!.tag].noofemployeestagged != "0"
            {
                commentsVC.assignEmpID = (self.reelModelArray[sender!.tag].tagPeoples?[0].orderAssigneeEmployeeID)!
                commentsVC.employeeID = (self.reelModelArray[sender!.tag].tagPeoples?[0].employeeID) ?? ""
            }
            commentsVC.desc = self.reelModelArray[sender!.tag].notes!
            commentsVC.empID = self.reelModelArray[sender!.tag].id!
            commentsVC.isFromIllDoIT = true
            commentsVC.postid = self.reelModelArray[sender!.tag].id!
            commentsVC.createdBy = self.reelModelArray[sender!.tag].createdBy!
            commentsVC.noofemployeestagged = self.reelModelArray[sender!.tag].noofemployeestagged ?? "0"
            commentsVC.taskCreatedby = self.reelModelArray[sender!.tag].createdBy!
            
    //            commentsVC.postPeopleSelected = self.reelsModelArray[sender!.tag].tagPeoples?[0]
            //        statusVC.dueDate = dateHelper(srt: self.reelsModelArray[sender!.tag].commissionNoOfDays1!)
            self.navigationController?.pushViewController(commentsVC, animated: true)
            
        }
        
        else if sender?.titleLabel?.text ==  "Approve"{
            let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            postVC.reelsModelArray = self.reelModelArray
            postVC.index = sender!.tag
            postVC.isFromEdit = true
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    @objc func commentsBtnTapped(_ sender: UIButton?) {
        print("Comment Tapped")
        if userID == self.reelModelArray[sender!.tag].createdBy
        {
//            let statusVC = storyboard?.instantiateViewController(identifier: "ViewStatusViewController") as! ViewStatusViewController
//            statusVC.postID = self.reelModelArray[sender!.tag].id!
//            statusVC.notes = self.reelModelArray[sender!.tag].notes!
//            statusVC.dueDate = dateHelper(srt: self.reelModelArray[sender!.tag].commissionNoOfDays1!)
//            statusVC.reelsModelArray = self.reelModelArray
//            statusVC.index = sender!.tag
//            self.navigationController?.pushViewController(statusVC, animated: true)
        }
        else
        {
//            let commentsVC = storyboard?.instantiateViewController(identifier: "CommentsViewController") as! CommentsViewController
//
//            commentsVC.assignEmpID = (self.reelModelArray[sender!.tag].tagPeoples?[0].orderAssigneeEmployeeID)!
//            commentsVC.desc = self.reelModelArray[sender!.tag].notes!
//            commentsVC.empID = self.reelModelArray[sender!.tag].id!
//            commentsVC.employeeID = (self.reelModelArray[sender!.tag].tagPeoples?[0].employeeID)!
//            commentsVC.postid = self.reelModelArray[sender!.tag].id!
//            commentsVC.createdBy = self.reelModelArray[sender!.tag].createdBy!
//            //        statusVC.dueDate = dateHelper(srt: self.reelModelArray[sender!.tag].commissionNoOfDays1!)
//            self.navigationController?.pushViewController(commentsVC, animated: true)
        }
        let commentsVC = storyboard?.instantiateViewController(identifier: "CommentsViewController") as! CommentsViewController
       
        commentsVC.assignEmpID = (self.reelModelArray[sender!.tag].tagPeoples?[0].orderAssigneeEmployeeID)!
        commentsVC.desc = self.reelModelArray[sender!.tag].notes!
        commentsVC.empID = self.reelModelArray[sender!.tag].id!
        commentsVC.employeeID = (self.reelModelArray[sender!.tag].tagPeoples?[0].employeeID)!
        commentsVC.postid = self.reelModelArray[sender!.tag].id!
        commentsVC.createdBy = self.reelModelArray[sender!.tag].createdBy!
        commentsVC.noofemployeestagged = self.reelModelArray[sender!.tag].noofemployeestagged ?? "0"
        commentsVC.taskCreatedby = self.reelModelArray[sender!.tag].createdBy!

        //        statusVC.dueDate = dateHelper(srt: self.reelModelArray[sender!.tag].commissionNoOfDays1!)
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    @objc func editBtnTapped(_ sender: UIButton?) {
        print("Edit Tapped")
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        postVC.reelsModelArray = self.reelModelArray
        postVC.index = sender!.tag
        postVC.isFromEdit = true
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
}
