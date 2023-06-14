//
//  CommentsViewController.swift
//  Done
//
//  Created by Mac on 13/06/23.
//

import UIKit

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var commentTF : UITextField!
    @IBOutlet weak var commentTB : UITableView!
    @IBOutlet weak var descLbl : UILabel!
    var desc = ""
    var empIDID = ""
    var commentsArray = [CommentsData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTB.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentsTableViewCell")
        
        self.commentTB.rowHeight = UITableView.automaticDimension
        self.commentTB.estimatedRowHeight = 70
        self.commentTB.delegate = self
        self.commentTB.dataSource = self
        
        self.descLbl.text = desc
        let paddingView: UIView = UIView(frame: CGRect(x: 5, y: 5, width: 5, height: 20))
        commentTF.leftView = paddingView
        commentTF.leftViewMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllCommentsAPICall(withEmpID: empIDID)
    }
    
    func getAllCommentsAPICall(withEmpID : String)
    {
        let commentAPI = BASEURL + GETCOMMENTSAPI + withEmpID
        APIModel.getRequest(strURL: commentAPI, postHeaders: headers as NSDictionary) { jsonData in
            let commentsResponse = try? JSONDecoder().decode(CommentsResponseModel.self, from: jsonData as! Data)
            if commentsResponse?.data != nil{
                self.commentsArray = (commentsResponse?.data)!
                self.commentTB.reloadData()
            }
            else
            {
                print("No Comments found")
            }
        } failure: { error in
            print(error
            )
        }
    }
}

extension CommentsViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell", for: indexPath) as! CommentsTableViewCell
        cell.userNameLbl.text = self.commentsArray[indexPath.row].createdBy
        cell.commentLbl.text = self.commentsArray[indexPath.row].comment
        
        let sourceTimeZone = TimeZone(identifier: "America/Los_Angeles")!
        let dateString = self.commentsArray[indexPath.row].createdAt  // 2023-06-13 14:21:33
        let format = "yyyy-MM-dd HH:mm:ss"
        
        if let convertedDate = convertDate(from: sourceTimeZone, to: TimeZone.current, dateString: dateString!, format: format) {
            print("Converted Date: \(convertedDate)")
            let time = getRequiredFormat(dateStrInTwentyFourHourFomat: convertedDate)
            cell.dateLbl.text = time ?? ""
        } else {
            print("Failed to convert date.")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension CommentsViewController {
    
    @IBAction func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendCommentBtnAction()
    {
        
    }
}
