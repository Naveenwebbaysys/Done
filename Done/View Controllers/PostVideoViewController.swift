//
//  SnapVideoViewController.swift
//  Done
//
//  Created by Mac on 02/06/23.
//

import UIKit
import AVFoundation
import AWSS3
import AWSCore
import KRProgressHUD
import iOSDropDown

class PostViewController: UIViewController,MyDataSendingDelegateProtocol {
    
    func sendDataToFirstViewController(tagsID: [String], tagname: [String]) {
//        self.tagIDSArray = tagsID
//        self.tagPeoples1 = tagname
        self.tagIDSArray.append(contentsOf: tagsID)
        self.tagPeoples1.append(contentsOf: tagname)
        self.tagPeopleLbl.text = self.tagPeoples1.joined(separator: ", ")
        print(self.tagPeopleLbl.text as Any)
    }
    

    var todaysDate = ""
    var futureDate = ""
    var placeholder = "Decription.."
    var recordVideoURL = ""
    var uuid = ""
    var awsS3Url = ""
    var tagPeoples1 =  [String]()
    let addLinks1 = [String]()
    var tagIDSArray =  [String]()
    var editURL = ""
    var postID = ""
    @IBOutlet weak var  descriptionTV : UITextView!
    @IBOutlet weak var  commissionTypeVW : UIStackView!
    @IBOutlet weak var  commissionTypeLbl : UILabel!
    @IBOutlet weak var  increseBtn : UIButton!
    @IBOutlet weak var  decreaseBtn : UIButton!
    @IBOutlet weak var  restrictVW : UIStackView!
    @IBOutlet weak var  assigenedBtn : UIButton!
    @IBOutlet weak var  everyOneBtn : UIButton!
    @IBOutlet weak var  restrictLbl : UILabel!
    @IBOutlet weak var  commissionTF : UILabel!
    @IBOutlet weak var  dateLbl : UILabel!
    @IBOutlet weak var  amountTF : UITextField!
    @IBOutlet weak var  linksTF : UITextField!
    @IBOutlet weak var  tagPeopleLbl : UILabel!
    
    
    var reelsModelArray = [Post]()
    var index = 0
    var isFromEdit = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTF.delegate = self
        descriptionTV.text = placeholder
        descriptionTV.textColor = .lightGray
        descriptionTV.delegate = self
        commissionTypeLbl.text = "Increase"
        restrictLbl.text = "Everyone"
        
        print(isFromEdit)
        
        if isFromEdit == true {
            
            descriptionTV.text = self.reelsModelArray[index].notes ?? ""
            descriptionTV.textColor = .black
            amountTF.text = self.reelsModelArray[index].commissionAmount ?? ""
            commissionTypeLbl.text = self.reelsModelArray[index].commissionType ?? ""
            restrictLbl.text = self.reelsModelArray[index].videoRestriction ?? ""
            for (i, _) in self.reelsModelArray[index].tagPeoples!.enumerated() {
                self.tagIDSArray.append(self.reelsModelArray[index].tagPeoples![i].employeeID!)
                self.tagPeoples1.append(self.reelsModelArray[index].tagPeoples![i].employeename!)
            }
            self.tagPeopleLbl.text = self.tagPeoples1.joined(separator: ", ")
            print(self.tagPeopleLbl.text as Any)
            editURL = self.reelsModelArray[index].videoURL ?? ""
            postID = self.reelsModelArray[index].id ?? ""
            
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        self.getTagUsersAPICall()
        let todayDate = NSDate.now
        print(todayDate)
        let dateFormatter1 = DateFormatter()
        let dateFormatter2 = DateFormatter()
        dateFormatter1.dateFormat = "MMM d, yyyy"
        dateFormatter2.dateFormat = "yyyy-MM-dd"
        todaysDate = dateFormatter2.string(from: Date())
        
        let monthsToAdd = 1
        var dateComponent = DateComponents()
        dateComponent.month = monthsToAdd
        let xyz = Calendar.current.date(byAdding: dateComponent, to: Date())!
        
        futureDate = dateFormatter2.string(from: xyz)
        print(todaysDate)
        print(futureDate)
        
        self.dateLbl.text = dateFormatter1.string(from: Date())
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
}


extension PostViewController {
    
    func uploadVideoToS3Server (filePath : String)
    {
        KRProgressHUD.show()
        let videoUrl = URL(fileURLWithPath: filePath)
        AWSS3Manager.shared.uploadVideo(videoUrl: videoUrl, progress: { [weak self] (progress) in
            KRProgressHUD.dismiss()
            guard let strongSelf = self else { return }
        }) { [weak self] (uploadedFileUrl, error) in
            guard let strongSelf = self else { return }
            if let awsS3Url = uploadedFileUrl as? String {
                print("Uploaded file url: " + awsS3Url)
                let awsS3Url = SERVERURL + awsS3Url
                self?.createPostAPICall(str: awsS3Url)
            } else {
                print("\(String(describing: error?.localizedDescription))")
                self!.showToast(message: error!.localizedDescription)
            }
        }
    }
    
    func createPostAPICall(str : String)
    {
        var descText = ""
        var commAmount =  ""
        var commType = ""
        var restType = ""
        DispatchQueue.main.async { [self] in
            descText = self.descriptionTV.text == "Decription.." ? "" : self.descriptionTV.text
            commAmount =  amountTF.text ?? ""
            commType = commissionTypeLbl.text ?? ""
            restType = restrictLbl.text ?? ""
            print(descText)
            print(commAmount)
            print(commType)
            print(restType)
            let postparams = PostRequestModel(videoURL: str, tagPeoples: tagIDSArray, addLinks: addLinks1, tags: [], videoRestriction: restType, description: descText, assignedDate: todaysDate, commissionType: commType, commissionAmount: commAmount, dueDate: futureDate)
            let jsonData = try! JSONEncoder().encode(postparams)
            let params11 = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            print(params11!)
            APIModel.postRequest(strURL: BASEURL + CREATEPOSTURL as NSString , postParams: postparams, postHeaders: headers as NSDictionary) { result in
                print(result)
                let postResponse = try? JSONDecoder().decode(PostResponseModel.self, from: result as! Data)
                if postResponse?.status == true
                {
                    if let compressedVideoPath = UserDefaults.standard.value(forKey: "compressedVideoPath") {
                        do {
                            print(compressedVideoPath)
                            deleteVideoFromLocal(path: compressedVideoPath as! String)
                        }
                    }
                    self.setRootVC()
                }
                else
                {
                    print("Error")
                }
                
            } failureHandler: { error in
                print(error)
            }
        }
    }
    
    func updatePostAPICall(str : String)
    {
        var descText = ""
        var commAmount =  ""
        var commType = ""
        var restType = ""
        DispatchQueue.main.async { [self] in
            descText = self.descriptionTV.text == "Decription.." ? "" : self.descriptionTV.text
            commAmount =  amountTF.text ?? ""
            commType = commissionTypeLbl.text ?? ""
            restType = restrictLbl.text ?? ""
            print(descText)
            print(commAmount)
            print(commType)
            print(restType)
            let postparams = UpdatePostRequestModel(videoURL: str, tagPeoples: tagIDSArray, addLinks: addLinks1, tags: [], videoRestriction: restType, description: descText, assignedDate: todaysDate, commissionType: commType, commissionAmount: commAmount, dueDate: futureDate, id: postID)
            let jsonData = try! JSONEncoder().encode(postparams)
            let params11 = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            print(params11!)
            APIModel.putRequest(strURL: BASEURL + UPDATEPOSTAPI as NSString , postParams: postparams, postHeaders: headers as NSDictionary) { result in
                print(result)
                let postResponse = try? JSONDecoder().decode(PostResponseModel.self, from: result as! Data)
                if postResponse?.status == true
                {
                    self.setRootVC()
                }
                else
                {
                    print("Error")
                }
                
            } failureHandler: { error in
                print(error)
            }
        }
    }
}



extension PostViewController : UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTV.textColor == .lightGray {
            descriptionTV.text = ""
            descriptionTV.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        descriptionTV.resignFirstResponder()
        if textView.text.isEmpty {
            descriptionTV.text = "Decription.."
            textView.textColor = UIColor.lightGray
            placeholder = ""
        } else {
            placeholder = descriptionTV.text
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder = descriptionTV.text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        amountTF.resignFirstResponder()
        amountTF.borderWidth = 0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 5
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
}





extension PostViewController  {

    @IBAction func commissiondropBtnAction(){
        
        commissionTypeVW.isHidden = false
    }
    
    @IBAction func restrictionBtnAction(){
        
        restrictVW.isHidden = false
    }
    
    
    @IBAction func increseBtnAction(){
        commissionTypeVW.isHidden = true
        commissionTypeLbl.text = "Increase"
    }
    
    @IBAction func decreaseAction(){
        commissionTypeVW.isHidden = true
        commissionTypeLbl.text = "Decrease"
    }
    @IBAction func assigenedBtnAction(){
        restrictVW.isHidden = true
        restrictLbl.text = "Assigned People"
    }
    
    @IBAction func everyOneBtnAction(){
        
        restrictVW.isHidden = true
        restrictLbl.text = "Everyone"
    }
    
    @IBAction func tagUsersAction (){
        amountTF.resignFirstResponder()
        descriptionTV.resignFirstResponder()
        let tagsVC = storyboard?.instantiateViewController(identifier: "TagsUsersViewController") as! TagsUsersViewController
        tagsVC.delegate = self
        self.navigationController?.pushViewController(tagsVC, animated: true)
    }
    
    @IBAction func postBtnAction(){
        if let recordVideo = UserDefaults.standard.value(forKey: "compressedVideoPath") as? String
        {
            recordVideoURL = recordVideo
        }
        print("recordVideoURL -> " + recordVideoURL)
        
        if amountTF.text == "" {
            amountTF.borderWidth = 1
            amountTF.borderColor = .red
            amountTF.cornerRadius = 6
        }
        else if tagPeoples1.count == 0
        {
            showToast(message: "Please select tag people")
        }
        else
        {
            amountTF.borderWidth = 0
            
            
            if isFromEdit == true
            {
                self.createPostAPICall(str: editURL)
            }
            else
            {
                uploadVideoToS3Server(filePath: recordVideoURL)
            }
            
           
        }
    }
    
    @IBAction func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
}
