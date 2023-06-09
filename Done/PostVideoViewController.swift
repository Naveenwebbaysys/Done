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

class PostViewController: UIViewController {
    
    var todaysDate = ""
    var futureDate = ""
    
    var placeholder = "Decription.."
    var recordVideoURL = ""
    var uuid = ""
    var awsS3Url = ""
    var tagsTableVw  = UITableView()
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
    
    var tagPeoples1 =  [String]()
    let addLinks1 = [String]()
    var tags1 =  [String]()
    var tagsUsersArray  =  [TagUsers]()
    
    var screen = UIScreen().bounds.size
    var bottomVW : UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        v.backgroundColor = UIColor.red
        v.layer.cornerRadius = 45
        return v
    }()
    
    var doneBtn : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.backgroundColor = UIColor(hex:"98C455")
        button.tintColor = .white
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Done", for: .normal)
        button.cornerRadius = 25
        
        return button
    }()
    
    var backBtn : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.tintColor = .black
        return button
    }()
    
    var topView : UIView = {
        let button = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.backgroundColor = UIColor(hex:"98C455")

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        awss3Setup()
        
        amountTF.delegate = self
        
        descriptionTV.text = placeholder
        descriptionTV.textColor = .lightGray
        descriptionTV.delegate = self
        
        commissionTypeLbl.text = "Increase"
        restrictLbl.text = "Everyone"
        
        
        self.tagsTableVw.register(UINib(nibName: "TagUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "TagUsersTableViewCell")
        tagsTableVw.delegate = self
        tagsTableVw.dataSource = self
        
        tagsTableVw.separatorStyle = .none
        tagsTableVw.tableFooterView = UIView()
        
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getTagUsersAPICall()
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
        
        UIView.animate(withDuration: 0.5) {
            self.bottomVW.center.y += self.bottomVW.frame.height + 100
        }
    }
    
    func tagUserssetup(){
        bottomVW.backgroundColor = .white
        
        bottomVW.frame = CGRect(x: 0, y: self.view.height, width: self.view.width, height: self.view.height - 50)
        tagsTableVw.frame = CGRect(x: 0, y: 20, width: bottomVW.frame.width, height: bottomVW.frame.height - 170)
        doneBtn.center = CGPoint(x: bottomVW.frame.size.width/2, y: tagsTableVw.frame.maxY + 30)
        
        print(bottomVW.frame)
        
        self.view.addSubview(bottomVW)
        self.view.bringSubviewToFront(bottomVW)
        self.bottomVW.addSubview(doneBtn)
        self.bottomVW.addSubview(tagsTableVw)
        
        UIView.animate(withDuration: 0.5) {
            self.bottomVW.center.y -= self.bottomVW.frame.height
            print(self.bottomVW.center.y)
        }
        
        doneBtn.addTarget(self, action: #selector(hidetagusers), for: .touchUpInside)
    }
    
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
        tagUserssetup()
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
            uploadVideoToS3Server(filePath: recordVideoURL)
        }
        
    }
    
    @objc func hidetagusers(){
        UIView.animate(withDuration: 0.5) {
            self.bottomVW.center.y += self.bottomVW.frame.height + 100
        }
    }
    
    func getTagUsersAPICall(){
        
        serviceController.getRequest(strURL: BASEURL + GETTAGUSERS, postHeaders: headers as NSDictionary) { jsonData in
            print(jsonData)
            let tagsResponseModel = try? JSONDecoder().decode(TagsResponseModel.self, from: jsonData as! Data)
            if tagsResponseModel?.data != nil
            {
                self.tagsUsersArray = (tagsResponseModel?.data)!
            }
            else
            {
                print("Tag users data empty")
            }
            
        } failure: { error in
            print(error)
            
        }
        
    }
    
}

extension PostViewController {
    func awss3Setup ()
    {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .USWest1, credentialsProvider: credentialsProvider)
        
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: AWSS3TransferUtilityConfiguration(),
            forKey: "S3TransferUtilityKey"
        )
    }
    
    func uploadVideoToS3Server (filePath : String)
    {
        KRProgressHUD.show()
        let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "S3TransferUtilityKey")
        let fileURL = URL(fileURLWithPath: filePath)
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.progressBlock = { task, progress in
            // Handle progress updates if needed "iosdone/" +
        }
        uuid = UUID().uuidString
        
        transferUtility?.uploadFile(
            fileURL,
            bucket: BUCKET_NAME,
            key: "iosdone/" + uuid + ".MOV",
            contentType: "video/MOV",
            expression: uploadExpression,
            completionHandler: { [self] task, error in
                KRProgressHUD.dismiss()
                if let error = error {
                    // Handle the error
                    print("Upload error: \(error.localizedDescription)")
                    self.showToast(message: error.localizedDescription)
                    return
                }
                // The upload task completed successfully
                print("Upload completed successfully")
                
                // You can access the uploaded file URL using the task's response property
                if let response = task.response {
                    let fileURL = response.url
                    print("Uploaded file URL: \(String(describing: fileURL))")
                    print("Base URL: " + "https://d1g0ba8hbbwly8.cloudfront.net")
                    print("Split URL: \(String(describing: response.url?.relativePath))")
                    awsS3Url = SERVERURL + response.url!.relativePath
                    createPostAPICall(str: awsS3Url)
                }
            }
        )
    }
    
    func createPostAPICall(str : String)
    {
        var descText = ""
        var commAmount =  ""
        var commType = ""
        var restType = ""
        DispatchQueue.main.async { [self] in
            descText = self.descriptionTV.text
            commAmount =  amountTF.text ?? ""
            commType = commissionTypeLbl.text ?? ""
            restType = restrictLbl.text ?? ""
        }
        
        print(descText)
        print(commAmount)
        print(commType)
        print(restType)
        
        let postparams = PostRequestModel(videoURL: str, tagPeoples: tagPeoples1, addLinks: addLinks1, tags: tags1, videoRestriction: restType, description: descText, assignedDate: todaysDate, commissionType: commType, commissionAmount: commAmount, dueDate: futureDate)
        
        let jsonData = try! JSONEncoder().encode(postparams)
        let params11 = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
        print(params11!)
        serviceController.postRequest(strURL: BASEURL + CREATEPOSTURL as NSString , postParams: postparams, postHeaders: headers as NSDictionary) { result in
            print(result)
            let postResponse = try? JSONDecoder().decode(PostResponseModel.self, from: result as! Data)
            if postResponse?.status == true
            {
                if let compressedVideoPath = UserDefaults.standard.value(forKey: "compressedVideoPath") as? URL {
                    self.removeUrlFromFileManager(compressedVideoPath)
                    if let originalVideoPath = UserDefaults.standard.value(forKey: "originalVideoPath") as? URL {
                        self.removeUrlFromFileManager(originalVideoPath)
                    }
                    
                }
                
                let story = UIStoryboard(name: "Main", bundle:nil)
                let vc = story.instantiateViewController(withIdentifier: "CustomViewController") as! CustomViewController
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
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


extension PostViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tagsUsersArray.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagUsersTableViewCell", for: indexPath) as! TagUsersTableViewCell
        
        cell.taguserNameLbl.text = self.tagsUsersArray[indexPath.row].firstName ?? "" +  (self.tagsUsersArray[indexPath.row].lastName ?? "")
        cell.seletionBtn.addTarget(self, action: #selector(selectuserAction), for: .touchUpInside)
        cell.seletionBtn.tag = indexPath.row
        
        let id = self.tagsUsersArray[indexPath.row].id!
        
        if self.tagPeoples1.contains(id){
        
            cell.seletionBtn.setImage(UIImage(systemName: "circlebadge.fill"), for: .normal)
            cell.seletionBtn.tintColor = UIColor(hex:"98C455")
        }else{
      
            cell.seletionBtn.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            cell.seletionBtn.tintColor = .darkGray
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    @objc func selectuserAction(_ sender : UIButton){
        
        if self.tagPeoples1.contains(self.tagsUsersArray[sender.tag].id!){
            if let idx = self.tagPeoples1.firstIndex(where: { $0 == self.tagsUsersArray[sender.tag].id!}) {
                self.tagPeoples1.remove(at: idx)
                self.tags1.remove(at: idx)
                }
        }
        else{
                self.tagPeoples1.append(self.tagsUsersArray[sender.tag].id!)
            self.tags1.append(self.tagsUsersArray[sender.tag].firstName!)
            }
        
        print(self.tagPeoples1)
        print(self.tags1)
//        self.tagsTableVw.reloadData()
        
        let indexPathRow:Int = sender.tag
        let indexPosition = IndexPath(row: indexPathRow, section: 0)
        self.tagsTableVw.reloadRows(at: [indexPosition], with: .none)
        
        self.tagPeopleLbl.text = self.tags1.joined(separator: ", ")
        print(self.tagPeopleLbl.text as Any)
    }
}
