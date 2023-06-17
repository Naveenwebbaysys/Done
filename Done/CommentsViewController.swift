//
//  CommentsViewController.swift
//  Done
//
//  Created by Mac on 13/06/23.
//

import UIKit
import IQKeyboardManagerSwift


class CommentsViewController: UIViewController {
    
    @IBOutlet weak var commentTF : UITextField!
    @IBOutlet weak var commentTB : UITableView!
    @IBOutlet weak var descLbl : UILabel!
    var desc = ""
    var assignEmpID = ""
    var empID = ""
    var createdBy = ""
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
        getAllCommentsAPICall(withEmpID: assignEmpID)
        
        if let id = UserDefaults.standard.value(forKey: UserDetails.userId){
            empID = id as! String
        }
        if let name = UserDefaults.standard.value(forKey: UserDetails.userName){
            createdBy = name as! String
        }
//        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
//        IQKeyboardManager.shared.enable = true
    }
    
    func getAllCommentsAPICall(withEmpID : String)
    {
        let commentAPI = BASEURL + GETCOMMENTSAPI + withEmpID
        APIModel.getRequest(strURL: commentAPI, postHeaders: headers as NSDictionary) { jsonData in
            let commentsResponse = try? JSONDecoder().decode(CommentsResponseModel.self, from: jsonData as! Data)
            if commentsResponse?.data != nil{
                self.commentsArray = (commentsResponse?.data)!
                DispatchQueue.main.async {
                    self.commentTB.reloadData()
     
                    let indexPosition = IndexPath(row: self.commentsArray.count - 1, section: 0)
                    
                    self.commentTB.scrollToRow(at: indexPosition, at: .bottom, animated: false)
                }
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
//        cell.commentLbl.numberOfLines = 0
        cell.commentLbl.text = self.commentsArray[indexPath.row].comment
        
        let sourceTimeZone = TimeZone(identifier: "America/Los_Angeles")!
        let dateString = self.commentsArray[indexPath.row].createdAt  // 2023-06-13 14:21:33
        let format = "yyyy-MM-dd HH:mm:ss"
        
        if let convertedDate = convertDate(from: sourceTimeZone, to: TimeZone.current, dateString: dateString!, format: format) {
            print("Converted Date: \(convertedDate)")
            let time = getRequiredFormat(dateStrInTwentyFourHourFomat: convertedDate)
            print(time)
            
            let newDate = checkDate(givenDate: time!)
            print(newDate)
            cell.dateLbl.text = newDate
            
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
        print(self.commentsArray.count)
        if commentTF.text != ""
        {
            let postparams = PostCommentModel(assigneeEmployeeID: Int(assignEmpID), employeeID: Int(empID), comment: commentTF.text, commenttype: "text")
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                APIModel.backGroundPostRequest(strURL: BASEURL + CREATEPOSTAPI as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { jsonResult in
                    print(jsonResult)
                    let destinationTime = TimeZone(identifier: "America/Los_Angeles")!
                    // 2023-06-13 14:21:33
                    let format = "yyyy-MM-dd HH:mm:ss"
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    let today = getcommentTimeFormat(dateStrInTwentyFourHourFomat: dateFormatter.string(from: Date()))
                    let createdAt = convertDate(from: TimeZone.current, to: destinationTime, dateString: today!, format: format)
                    //                print(createdAt)
                    let newcomment =  CommentsData(id: "0", assigneeEmployeeID: self.assignEmpID, createdAt: createdAt, comment: self.commentTF.text, employeeID: self.empID, createdBy: self.createdBy, commenttype: "Test")
                    self.commentsArray.append(newcomment)
//                    self.commentTB.reloadData()
                    print(self.commentsArray.count)
                    DispatchQueue.main.async {
                        let section = 0 // Assuming you have only one section
                        let lastRow = self.commentTB.numberOfRows(inSection: section)
                        let lastRowIndexPath = IndexPath(row: lastRow, section: section)
                        self.commentTB.insertRows(at: [lastRowIndexPath], with: .none)
                        self.commentTB.scrollToRow(at: lastRowIndexPath, at: .bottom, animated: false)
                    }
                    self.commentTF.text = ""
                    self.commentTF.resignFirstResponder()
                } failureHandler: { error in
                    print(error)
                }
                DispatchQueue.main.async {
                    print("This is run on the main queue, after the previous code in outer block")
                }
            }
        }
    }
}



extension CommentsViewController {
    
    func checkDate(givenDate :String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy hh:mm a"
        let givenDateString = givenDate
        let givenDate = dateFormatter.date(from: givenDateString)!
        let calendar = Calendar.current
        if calendar.isDateInToday(givenDate) {
            dateFormatter.dateFormat = "hh:mm a"
            let currentTimeString = dateFormatter.string(from: givenDate)
            print("Today, \(currentTimeString)")
            return currentTimeString
        } else {
            let formattedDateString = dateFormatter.string(from: givenDate)
            print(formattedDateString)
            return formattedDateString
        }
    }
}
