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
//import iOSDropDown
import DropDown
import MaterialComponents


class PostViewController: UIViewController,MyDataSendingDelegateProtocol {
    
    func sendDataToFirstViewController(tagsID: [String], tagname: [String]) {
        self.tagIDSArray = tagsID
        self.tagPeoples1 = tagname
        //        self.tagIDSArray.append(contentsOf: tagsID)
        //        self.tagPeoples1.append(contentsOf: tagname)
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
//    let addLinks1 = [String]()
    var tagIDSArray =  [String]()
    var editURL = ""
    var postID = ""
    
    @IBOutlet weak var screenTitleLbl : UILabel!
    @IBOutlet weak var  descriptionTV : UITextView!
    @IBOutlet weak var  commissionTypeLbl : UILabel!
    @IBOutlet weak var  restrictLbl : UILabel!
    @IBOutlet weak var  dateLbl : UILabel!
    @IBOutlet weak var  amountTF : UITextField!
    @IBOutlet weak var  linksTF : UITextField!
    @IBOutlet weak var  tagPeopleLbl : UILabel!
    @IBOutlet weak var  linksTW : UITableView!
    @IBOutlet weak var btnCommission: UIButton!
    @IBOutlet weak var btnRestrict: UIButton!
    @IBOutlet weak var btnProjectType: UIView!
    @IBOutlet weak var lblProjectType: UILabel!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var viewSubCategory: UIView!
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var lblSubCategoryTitle: UILabel!
    @IBOutlet weak var constraintTableviewHeight: NSLayoutConstraint!
   @IBOutlet weak var viewVideoUploadProgress: UIView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var constraintBtnPostWidth: NSLayoutConstraint!
    
    var reelsModelArray = [Post]()
    var index = 0
    var isFromEdit = Bool()
    let commissionTypeDropDown = DropDown()
    let restrictTypeDropDown = DropDown()
    let projectTypeDropDown = DropDown()
    let allCategoryDropDown = DropDown()
    let subCategoryDropDown = DropDown()
    var isOpenProject:Bool = true
    var arrAllCategory = [Category]()
    var arrSelectAllCategory = [Category]()
    var arrSubCategory = [Category]()
    var arrSelectSubCategory = [Category]()
    var arrLinkData = [String]()
    let progressView = MDCProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTF.delegate = self
        descriptionTV.text = placeholder
        descriptionTV.textColor = .lightGray
        descriptionTV.delegate = self
        commissionTypeLbl.text = "Increase"
        restrictLbl.text = "Assigned People"
        lblProjectType.text = "Open For Anyone To Work On"
        self.setProjectType()
        //        print(isFromEdit)
        self.linksTW.frame = CGRect(x: 5, y: linksTF.frame.maxY + 10, width: linksTF.frame.width, height: 200)
        linksTW.borderColor = .clear
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
            screenTitleLbl.text = "Update Gigs"
            if self.reelsModelArray[index].projectType == "open_for_anyone_to_work_on"{
                lblProjectType.text  = "Open For Anyone To Work On"
                self.viewSubCategory.isHidden = false
                self.viewCategory.isHidden = false
            }else{
                lblProjectType.text  = "Already Know Who I Want To Work On This Project"
                self.viewSubCategory.isHidden = true
                self.viewCategory.isHidden = true
            }
        
            self.getSubCategoryAPICall(id: self.reelsModelArray[index].categoryId ?? "")
            
            self.arrLinkData = self.reelsModelArray[index].addLinks ?? [String]()
            self.setTableviewHeight()
            self.btnPost.setTitle("Update", for: .normal)
            self.constraintBtnPostWidth.constant = 150
        }
        else
        {
            self.btnPost.setTitle("Save", for: .normal)
            self.constraintBtnPostWidth.constant = 100
            progressView.mode = .indeterminate
            progressView.progressTintColor = UIColor.init(red: 152/255, green: 196/255, blue: 85/255, alpha: 1.0)
            progressView.trackTintColor = UIColor.init(red: 152/255, green: 196/255, blue: 85/255, alpha: 0.4)
            progressView.frame = CGRect(x: 0, y: 0, width: viewVideoUploadProgress.bounds.width, height: viewVideoUploadProgress.bounds.height)
            progressView.layer.cornerRadius = 2.5
            self.viewVideoUploadProgress.addSubview(progressView)
            progressView.startAnimating()
            self.btnPost.isEnabled = false
            self.btnPost.backgroundColor = .lightGray
            if let recordVideo = UserDefaults.standard.value(forKey: "compressedVideoPath") as? String
            {
                recordVideoURL = recordVideo
            }
            print("recordVideoURL -> " + recordVideoURL)
            
            self.uploadVideoToS3Server(filePath: recordVideoURL)
        }
        
        commissionTypeDropDown.anchorView = btnCommission
        commissionTypeDropDown.dataSource = ["Increase", "Decrease"]
        commissionTypeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            commissionTypeLbl.text = item
        }
        
        restrictTypeDropDown.anchorView = btnRestrict
        restrictTypeDropDown.dataSource = ["Assigned People", "Everyone"]
        restrictTypeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            restrictLbl.text = item
        }
        
        projectTypeDropDown.anchorView = btnProjectType
        projectTypeDropDown.dataSource = ["Open For Anyone To Work On", "Already Know Who I Want To Work On This Project"]
        projectTypeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            lblProjectType.text = item
            self.isOpenProject = index == 0 ? true : false
            self.setProjectType()
        }
        
        allCategoryDropDown.anchorView = viewCategory
        allCategoryDropDown.backgroundColor = .white
        allCategoryDropDown.textColor = UIColor.init(red: 152/255, green: 196/255, blue: 85/255, alpha: 1.0)
        allCategoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            lblCategoryTitle.text = item
            if index != 0 {
                getSubCategoryAPICall(id: arrAllCategory[index - 1].id)
                self.arrSelectAllCategory = [arrAllCategory[index - 1]]
                self.viewSubCategory.isHidden = false
            }else{
                self.viewSubCategory.isHidden = true
            }
            
        }
        
        subCategoryDropDown.anchorView = viewSubCategory
        subCategoryDropDown.backgroundColor = .white
        subCategoryDropDown.textColor = UIColor.init(red: 152/255, green: 196/255, blue: 85/255, alpha: 1.0)
        subCategoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            lblSubCategoryTitle.text = item
            self.arrSelectSubCategory = [arrSubCategory[index - 1]]
        }
        
        self.getAllCategoryAPICall()
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
        
        self.dateLbl.text = dateFormatter1.string(from: xyz)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    @IBAction func commissiondropBtnAction(_ sender: UIButton) {
        commissionTypeDropDown.show()
    }
    
    @IBAction func restrictionBtnAction(_ sender: UIButton) {
        restrictTypeDropDown.show()
    }
    
    @IBAction func btnProjectType(_ sender: UIButton) {
        projectTypeDropDown.show()
        
    }
    
    @IBAction func btnCategoryAction(_ sender: UIButton) {
        var arrData: [String] = [String]()
        arrData.append("Select Category")
        for data in arrAllCategory{
            arrData.append(data.name)
        }
        
        allCategoryDropDown.dataSource = arrData
        allCategoryDropDown.show()
    }
    
    @IBAction func btnSubCategory(_ sender: UIButton) {
        var arrData: [String] = [String]()
        arrData.append("Select Sub Category")
        for data in arrSubCategory{
            arrData.append(data.name)
        }
//        print(arrData.count)
        subCategoryDropDown.dataSource = arrData
        subCategoryDropDown.show()
    }
    
    func setProjectType(){
        if isOpenProject{
            self.viewCategory.isHidden = false
        }else{
            self.viewCategory.isHidden = true
            self.viewSubCategory.isHidden = true
        }
    }
    
    @IBAction func btnAddLinkAction(_ sender: UIButton) {
        if !(linksTF.text ?? "").isEmpty{
            self.arrLinkData.append(linksTF.text ?? "")
            self.setTableviewHeight()
            self.linksTF.text = ""
        }
    
    }
    
    @objc func btnDeleteLink(_ sender : UIButton){
        self.arrLinkData.remove(at: sender.tag)
        self.setTableviewHeight()
    }
    
    func setTableviewHeight(){
        if arrLinkData.isEmpty{
            self.linksTW.isHidden = true
            self.constraintTableviewHeight.constant = 0
        }else{
            self.linksTW.isHidden = false
            self.linksTW.reloadData()
            self.constraintTableviewHeight.constant = CGFloat(40 * arrLinkData.count)
        }
       
    }
    
    func getAllCategoryAPICall(){
        let categoryAPI = BASEURL + CATEGORY_PROJECTTYPE
        APIModel.getRequest(strURL: categoryAPI, postHeaders: headers as NSDictionary) { jsonData in
            let categoryResponse = try? JSONDecoder().decode(CategoryResponseModel.self, from: jsonData as! Data)
            if categoryResponse?.data != nil{
                self.arrAllCategory = categoryResponse?.data.categories ?? [Category]()
                
                if self.isFromEdit == true{
                    let data = self.arrAllCategory.filter { Category in
                        Category.id == self.reelsModelArray[self.index].categoryId
                    }
                    if !data.isEmpty{
                        self.arrSelectAllCategory = data
                        self.lblCategoryTitle.text = data[0].name
                    }
                }
            }else{
                print("No Category found")
            }
        } failure: { error in
            print(error
            )
        }
    }
    
    func getSubCategoryAPICall(id:String){
        let categoryAPI = BASEURL + CATEGORY_PROJECTTYPE + "?parent_id=\(id)"
        APIModel.getRequest(strURL: categoryAPI, postHeaders: headers as NSDictionary) { jsonData in
            let categoryResponse = try? JSONDecoder().decode(CategoryResponseModel.self, from: jsonData as! Data)
            if categoryResponse?.data != nil{
                self.arrSubCategory = categoryResponse?.data.categories ?? [Category]()
                
                if self.isFromEdit == true{
                    let data = self.arrSubCategory.filter { Category in
                        Category.id == self.reelsModelArray[self.index].subcategoryId
                    }
                    if !data.isEmpty{
                        self.arrSelectSubCategory = data
                        self.lblSubCategoryTitle.text = data[0].name
                    }
                }
            }else{
                print("No Category found")
            }
        } failure: { error in
            print(error
            )
        }
    }
}


extension PostViewController {
    
    func uploadVideoToS3Server (filePath : String)
    {
        DispatchQueue.global(qos: .background).async {
            let videoUrl = URL(fileURLWithPath: filePath)
            AWSS3Manager.shared.uploadVideo(videoUrl: videoUrl, progress: { [weak self] (progress) in
                guard let strongSelf = self else { return }
            }) { [weak self] (uploadedFileUrl, error) in
                
                guard let strongSelf = self else { return }
                if let awsS3Url = uploadedFileUrl as? String {
                    print("Uploaded file url: " + awsS3Url)
                    self?.awsS3Url = SERVERURL + awsS3Url
                    self?.viewVideoUploadProgress.isHidden = true
                    self?.progressView.stopAnimating()
                    self?.btnPost.isEnabled = true
                    self?.btnPost.backgroundColor = UIColor.init(red: 152/255, green: 196/255, blue: 85/255, alpha: 1.0)
                    
                } else {
                    print("\(String(describing: error?.localizedDescription))")
                    self!.showToast(message: error!.localizedDescription)
                }
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
            
            var stCategoryID: String = ""
            if !arrSelectAllCategory.isEmpty{
                stCategoryID = arrSelectAllCategory[0].id
            }
            
            var stSubCategoryID: String = ""
            if !arrSelectSubCategory.isEmpty{
                stSubCategoryID = arrSelectSubCategory[0].id
            }
            
            var stProjectType: String = ""
            if (lblProjectType.text ?? "")  == "Open For Anyone To Work On"{
                stProjectType = "open_for_anyone_to_work_on"
            }else{
                stProjectType = "already_know_who_i_want_to_work_on_this_project"
            }
            KRProgressHUD.show()
           
            let postparams = PostRequestModel(videoURL: str, tagPeoples: tagIDSArray, addLinks: arrLinkData, tags: [], videoRestriction: restType, description: descText, assignedDate: todaysDate, commissionType: commType, commissionAmount: commAmount, dueDate: futureDate,categoryId: stCategoryID,subcategoryId: stSubCategoryID,projectType: stProjectType)
            let jsonData = try! JSONEncoder().encode(postparams)
            let params11 = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            print(params11!)
            APIModel.postRequest(strURL: BASEURL + CREATEPOSTURL as NSString , postParams: postparams, postHeaders: headers as NSDictionary) { result in
                print(result)
                KRProgressHUD.dismiss()
                let postResponse = try? JSONDecoder().decode(PostResponseModel.self, from: result as! Data)
                if postResponse?.status == true
                {
                    //                    if let compressedVideoPath = UserDefaults.standard.value(forKey: "compressedVideoPath") {
                    //                        do {
                    //                            print(compressedVideoPath)
                    //                            deleteVideoFromLocal(path: compressedVideoPath as! String)
                    //                        }
                    //                    }
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
            //            print(descText)
            //            print(commAmount)
            //            print(commType)
            //            print(restType)
            var stCategoryID: String = ""
            if !arrSelectAllCategory.isEmpty{
                stCategoryID = arrSelectAllCategory[0].id
            }
            
            var stSubCategoryID: String = ""
            if !arrSelectSubCategory.isEmpty{
                stSubCategoryID = arrSelectSubCategory[0].id
            }
            
            var stProjectType: String = ""
            print(lblProjectType.text ?? "")
            if (lblProjectType.text ?? "")  == "Open For Anyone To Work On"{
                stProjectType = "open_for_anyone_to_work_on"
            }else{
                stProjectType = "already_know_who_i_want_to_work_on_this_project"
            }
            
            let postparams = UpdatePostRequestModel(videoURL: str, tagPeoples: tagIDSArray, addLinks: arrLinkData, tags: [], videoRestriction: restType, description: descText, commissionType: commType, commissionAmount: commAmount, dueDate: futureDate, id: postID,categoryId: stCategoryID,subcategoryId: stSubCategoryID,projectType: stProjectType)
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


extension PostViewController :UITableViewDelegate,UITableViewDataSource{
    // MARK: - UITableview Delegate & DataSource Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLinkData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: AddLinksPostCell! = tableView.dequeueReusableCell(withIdentifier: "AddLinksPostCell") as? AddLinksPostCell
        if cell == nil {
            tableView.register(UINib(nibName: "AddLinksPostCell", bundle: nil), forCellReuseIdentifier:"AddLinksPostCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "AddLinksPostCell") as? AddLinksPostCell
        }
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: self.arrLinkData[indexPath.row], attributes: underlineAttribute)
        cell.lblLink.attributedText = underlineAttributedString
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(btnDeleteLink), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let url = URL(string: arrLinkData[indexPath.row]) else { return }
        UIApplication.shared.open(arrLinkData[indexPath.row].convertToUrl())
    }
}

extension PostViewController  {
    
    
    @IBAction func tagUsersAction (){
        amountTF.resignFirstResponder()
        descriptionTV.resignFirstResponder()
        let tagsVC = storyboard?.instantiateViewController(identifier: "TagsUsersViewController") as! TagsUsersViewController
        tagsVC.tags1 = self.tagIDSArray
        tagsVC.tagPeoples1 = self.tagPeoples1
        tagsVC.delegate = self
        self.navigationController?.pushViewController(tagsVC, animated: true)
    }
    
    @IBAction func postBtnAction(){
        if amountTF.text == "" {
            amountTF.borderWidth = 1
            amountTF.borderColor = .red
            amountTF.cornerRadius = 6
            return
        }
        
        
        if isOpenProject{
            if arrSelectAllCategory.isEmpty{
                showToast(message: "Please select category")
                return
            }
            
            if arrSelectSubCategory.isEmpty{
                showToast(message: "Please select sub category")
                return
            }
        }
        
        if tagPeoples1.count == 0
        {
            showToast(message: "Please select tag people")
            return
        }
        
        amountTF.borderWidth = 0
        if isFromEdit == true
        {
            self.updatePostAPICall(str: editURL)
        }
        else
        {
            self.createPostAPICall(str: awsS3Url)
        }
        
    }
    
    @IBAction func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
}

