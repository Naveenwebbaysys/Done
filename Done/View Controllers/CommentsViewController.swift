//
//  CommentsViewController.swift
//  Done
//
//  Created by Mac on 13/06/23.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage
import AVFoundation
import AVKit
import DropDown
import Photos

class CommentsViewController: UIViewController, UITextViewDelegate {
    
    //    @IBOutlet weak var commentTF : UITextField!
    @IBOutlet weak var commentTB : UITableView!
    @IBOutlet weak var descLbl : UILabel!
    @IBOutlet weak var constraintTxtCommentBottom: NSLayoutConstraint!
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var constraintTxtCommentHeight: NSLayoutConstraint!
    
    var taskCreatedby = ""
    var postid = ""
    var desc = ""
    var assignEmpID = ""
    var empID = ""
    var createdBy = ""
    var commentsArray = [CommentsData]()
    var postPeopleSelected: PostStatus?
    //    var orderAssigneeEmployeeID = ""
    var employeeID = ""
    var editCommentIndex: Int = -1
    //    var postCommentImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTB.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentsTableViewCell")
        self.commentTB.register(UINib(nibName: "ImageCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageCommentsTableViewCell")
        
        self.commentTB.rowHeight = UITableView.automaticDimension
        self.commentTB.estimatedRowHeight = 70
        self.commentTB.delegate = self
        self.commentTB.dataSource = self
        
        self.descLbl.text = desc
        
        
        
        
        
        IQKeyboardManager.shared.enable = false
        
        getAllCommentsAPICall(withEmpID: assignEmpID)
        
        if let id = UserDefaults.standard.value(forKey: UserDetails.userId){
            empID = id as! String
        }
        if let name = UserDefaults.standard.value(forKey: UserDetails.userName){
            createdBy = name as! String
        }
        
        commentTV.backgroundColor = .clear
        commentTV.text = "Comment..."
        commentTV.textColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //        readMsgAPICall(task: taskCreatedby, empid: empID, assignID: assignEmpID)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Remove observers in deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - KeyBoard Handler
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            var bottomPadding:CGFloat = 0
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.first
                bottomPadding = window?.safeAreaInsets.bottom ?? 0
            }
            constraintTxtCommentBottom.constant = keyboardHeight - bottomPadding
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        constraintTxtCommentBottom.constant = 5
        self.view.layoutIfNeeded()
    }
    
    @IBAction func cameraClick(_ sender: UIButton) {
        print("Camera click")
        
        let alertView = UIAlertController(title: "Please choose one", message: nil, preferredStyle: .actionSheet)
        let cameraAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    DispatchQueue.main.async {
                        let picker = UIImagePickerController()
                        picker.sourceType = .camera
                        picker.mediaTypes = ["public.image","public.movie"]
                        picker.delegate = self
                        picker.videoMaximumDuration = TimeInterval(30.0)
                        picker.allowsEditing = false
                        self.present(picker, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        let alertView = UIAlertController(title: "Are you sure?", message: "We appreciate your concern about denying this permission, but it will give you a seamless experience.", preferredStyle: .alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Allow Later", style: .cancel) { action -> Void in
                            alertView.dismiss(animated: true, completion: nil)
                        }
                        let allowNowAction: UIAlertAction = UIAlertAction(title: "Allow Now", style: .default) { action -> Void in
                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                        }
                        alertView.addAction(cancelAction)
                        alertView.addAction(allowNowAction)
                        let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
                        rootVC?.present(alertView, animated: true, completion: nil)
                    }
                }
            }
        }
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "Photo Library", style: .default) { action -> Void in
            self.galleryOpen()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        
        alertView.addAction(cameraAction)
        alertView.addAction(photoLibraryAction)
        alertView.addAction(cancelAction)
        let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
        rootVC?.present(alertView, animated: true, completion: nil)
    }
    
    func getAllCommentsAPICall(withEmpID : String)
    {
        let commentAPI = BASEURL + GETCOMMENTSAPI + withEmpID + "&page_no=1"
        APIModel.getRequest(strURL: commentAPI, postHeaders: headers as NSDictionary) { jsonData in
            let commentsResponse = try? JSONDecoder().decode(CommentsResponseModel.self, from: jsonData as! Data)
            if commentsResponse?.data != nil{
                self.commentsArray = (commentsResponse?.data)!
                DispatchQueue.main.async {
                    self.commentTB.reloadData()
                    self.tableviewBottomScroll()
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
    
    func getVideoThumbnail(url: URL) -> UIImage? {
        //let url = url as URL
        let request = URLRequest(url: url)
        let cache = URLCache.shared
        if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
            return image
        }
        
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 120, height: 120)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        var image: UIImage?
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            image = UIImage(cgImage: cgImage)
        } catch { }
        
        if let image = image, let data = image.pngData(), let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            let newImg = UIImage(data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
        
        return image
    }
    
    @objc func longTextPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            print("longpressed==",sender.view?.tag ?? 0)
            let cell = commentTB.cellForRow(at: IndexPath(row: sender.view?.tag ?? 0, section: 0)) as! CommentsTableViewCell
            let commentMenu = DropDown()
            commentMenu.anchorView = cell.viewBG
            commentMenu.bottomOffset = CGPoint(x: 5, y:(cell.viewBG.bounds.height))
            commentMenu.width = 250
            commentMenu.dataSource = ["Edit", "Delete"]
            commentMenu.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                if index == 0{
                    self.editCommentIndex = sender.view?.tag ?? 0
                    self.commentTV.text = commentsArray[self.editCommentIndex].comment ?? ""
                    commentTV.textColor = UIColor.black
                }else{
                    self.editCommentIndex = sender.view?.tag ?? 0
                    self.deleteAPICall()
                }
            }
            commentMenu.show()
        }
    }
    
    @objc func longImageVideoPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            print("longpressed==",sender.view?.tag ?? 0)
            let cell = commentTB.cellForRow(at: IndexPath(row: sender.view?.tag ?? 0, section: 0)) as! ImageCommentsTableViewCell
            let commentMenu = DropDown()
            commentMenu.anchorView = cell.viewComment
            commentMenu.bottomOffset = CGPoint(x: 5, y:(cell.viewComment.bounds.height))
            commentMenu.width = 250
            commentMenu.dataSource = ["Delete"]
            commentMenu.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                
                self.editCommentIndex = sender.view?.tag ?? 0
                self.deleteAPICall()
                
            }
            commentMenu.show()
        }
    }
    
    @objc func btnVideoPlayAction(_ sender : UIButton){
        let data = self.commentsArray[sender.tag]
        if (data.commenttype ?? "" ) == "video"{
            let stComment = data.comment ?? ""
            let arrComment = stComment.components(separatedBy: "--")
            if !arrComment.isEmpty{
                let VC = self.storyboard?.instantiateViewController(identifier: "VideoPerviewViewController") as! VideoPerviewViewController
                print(arrComment[0])
                VC.selectedVideoURL = arrComment[0]
                if arrComment.count > 1{
                    VC.selectedVideoComment = arrComment[1]
                }
                VC.modalPresentationStyle = .fullScreen
                self.present(VC, animated: true)
            }
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let oldString = textView.text {
            let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!,with: text)
            if !newString.isEmpty{
                constraintTxtCommentHeight.constant = self.commentTV.contentSize.height > 40 ? 55 : 40
            }else{
                self.constraintTxtCommentHeight.constant = 40
            }
        }else{
            self.constraintTxtCommentHeight.constant = 40
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func tableviewBottomScroll(){
        //        DispatchQueue.main.async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !self.commentsArray.isEmpty{
                let indexPath = IndexPath(row: self.commentsArray.count-1, section: 0)
                self.commentTB.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        //        }
    }
    func openPhotos(){
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.mediaTypes = ["public.image","public.movie"]
                picker.delegate = self
                picker.videoMaximumDuration = TimeInterval(30.0)
                picker.allowsEditing = false
                self.present(picker, animated: true)
            }
        }
    }
    func galleryOpen(){
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.openPhotos()
            break
        case .denied, .restricted :
            DispatchQueue.main.async {
                let alertView = UIAlertController(title: "Are you sure?", message: "We appreciate your concern about denying this permission, but it will give you a seamless experience.", preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Allow Later", style: .cancel) { action -> Void in
                    alertView.dismiss(animated: true, completion: nil)
                }
                let allowNowAction: UIAlertAction = UIAlertAction(title: "Allow Now", style: .default) { action -> Void in
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                }
                alertView.addAction(cancelAction)
                alertView.addAction(allowNowAction)
                let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
                rootVC?.present(alertView, animated: true, completion: nil)
            }
            break
        case .limited:
            self.openPhotos()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            let picker = UIImagePickerController()
                            picker.sourceType = .photoLibrary
                            picker.mediaTypes = ["public.image","public.movie"]
                            picker.delegate = self
                            picker.videoMaximumDuration = TimeInterval(30.0)
                            picker.allowsEditing = false
                            self.present(picker, animated: true)
                        }
                    }
                    break
                case .limited:
                    self.openPhotos()
                    break
                case .denied, .restricted:
                    DispatchQueue.main.async {
                        let alertView = UIAlertController(title: "Are you sure?", message: "We appreciate your concern about denying this permission, but it will give you a seamless experience.", preferredStyle: .alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Allow Later", style: .cancel) { action -> Void in
                            alertView.dismiss(animated: true, completion: nil)
                        }
                        let allowNowAction: UIAlertAction = UIAlertAction(title: "Allow Now", style: .default) { action -> Void in
                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                        }
                        alertView.addAction(cancelAction)
                        alertView.addAction(allowNowAction)
                        let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
                        rootVC?.present(alertView, animated: true, completion: nil)
                    }
                    break
                case .notDetermined:
                    break
                    
                @unknown default:
                    break
                }
            }
            
        @unknown default:
            break
        }
        
        
    }
}

extension CommentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            print("Selected image ",image)
            DispatchQueue.main.async {
                let VC = self.storyboard?.instantiateViewController(identifier: "ImageAndVideoCommentViewController") as! ImageAndVideoCommentViewController
                VC.selectedImage = image
                VC.postPeopleSelected = self.postPeopleSelected
                VC.postid = self.postid
                VC.delegate = self
                VC.orderAssigneeEmployeeID = self.assignEmpID
                VC.employeeID = self.employeeID
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }else if let videoUrl = info[.mediaURL] as? URL {
            print("Selected video ",videoUrl)
            DispatchQueue.main.async {
                let VC = self.storyboard?.instantiateViewController(identifier: "ImageAndVideoCommentViewController") as! ImageAndVideoCommentViewController
                VC.selectedVideoURL = videoUrl
                VC.postPeopleSelected = self.postPeopleSelected
                VC.postid = self.postid
                VC.delegate = self
                VC.orderAssigneeEmployeeID = self.assignEmpID
                VC.employeeID = self.employeeID
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }else{
            print("Data nooooooooo")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
}

extension CommentsViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.commentsArray[indexPath.row]
        if (data.commenttype ?? "" ) == "text"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell", for: indexPath) as! CommentsTableViewCell
            //            let currentIndex = commentsArray.count-1
            //            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
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
            cell.tag = indexPath.row
            if self.commentsArray[indexPath.row].employeeID == (UserDefaults.standard.value(forKey: UserDetails.userId) as! String){
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTextPressed))
                cell.addGestureRecognizer(longPressRecognizer)
            }
            
            return cell
        }else if (data.commenttype ?? "" ) == "video"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentsTableViewCell", for: indexPath) as! ImageCommentsTableViewCell
            //            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.userNameLbl.text = self.commentsArray[indexPath.row].createdBy
            cell.btnVideoPlay.isHidden = false
            cell.btnVideoPlay.tag = indexPath.row
            cell.btnVideoPlay.addTarget(self, action: #selector(btnVideoPlayAction), for: .touchUpInside)
            let stComment = self.commentsArray[indexPath.row].comment ?? ""
            let arrComment = stComment.components(separatedBy: "--")
            if !arrComment.isEmpty{
                cell.viewComment.isHidden = true
                
                DispatchQueue.global(qos: .background).async { [self] in
                    if (data.isLocalStore ?? false){
                        let videoUrl = URL(fileURLWithPath: arrComment[0])
                        DispatchQueue.main.async {
                            cell.commentImage.image = self.getVideoThumbnail(url: videoUrl)
                        }
                    }else{
                        let videoUrl = URL(string: arrComment[0])
                        DispatchQueue.main.async {
                            cell.commentImage.image = self.getVideoThumbnail(url: videoUrl!)
                        }
                    }
                }
                if arrComment.count > 1{
                    cell.viewComment.isHidden = false
                    cell.lblComment.text = arrComment[1]
                }
            }
            cell.tag = indexPath.row
            if self.commentsArray[indexPath.row].employeeID == (UserDefaults.standard.value(forKey: UserDetails.userId) as! String){
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longImageVideoPressed))
                cell.addGestureRecognizer(longPressRecognizer)
            }
            
            let sourceTimeZone = TimeZone(identifier: "America/Los_Angeles")!
            let dateString = self.commentsArray[indexPath.row].createdAt  // 2023-06-13 14:21:33
            let format = "yyyy-MM-dd HH:mm:ss"
            
            if let convertedDate = convertDate(from: sourceTimeZone, to: TimeZone.current, dateString: dateString!, format: format) {
                //                print("Converted Date: \(convertedDate)")
                let time = getRequiredFormat(dateStrInTwentyFourHourFomat: convertedDate)
                let newDate = checkDate(givenDate: time!)
                cell.dateLbl.text = newDate
                
            } else {
                print("Failed to convert date.")
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentsTableViewCell", for: indexPath) as! ImageCommentsTableViewCell
            //            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.userNameLbl.text = self.commentsArray[indexPath.row].createdBy
            cell.btnVideoPlay.isHidden = true
            cell.viewComment.isHidden = true
            if (data.isLocalStore ?? false){
                cell.commentImage.image = UIImage(data: data.isLocalImageData ?? Data())
                if !(data.comment ?? "").isEmpty{
                    cell.viewComment.isHidden = false
                    cell.lblComment.text = data.comment ?? ""
                }
            }else{
                let stComment = self.commentsArray[indexPath.row].comment ?? ""
                let arrComment = stComment.components(separatedBy: "--")
                if !arrComment.isEmpty{
                    cell.viewComment.isHidden = true
                    cell.commentImage.sd_setImage(with: URL.init(string: arrComment[0]), placeholderImage: nil, options: .highPriority) { (imge, error, cache, url) in
                        if error == nil{
                            cell.commentImage.image = imge
                        }else{
                            //                        cell.commentImage.image = UIImage(named: "ic_placeholder_neutral")
                        }
                    }
                    
                    if arrComment.count > 1{
                        cell.viewComment.isHidden = false
                        cell.lblComment.text = arrComment[1]
                    }
                }
            }
            
            let sourceTimeZone = TimeZone(identifier: "America/Los_Angeles")!
            let dateString = self.commentsArray[indexPath.row].createdAt  // 2023-06-13 14:21:33
            let format = "yyyy-MM-dd HH:mm:ss"
            cell.tag = indexPath.row
            if self.commentsArray[indexPath.row].employeeID == (UserDefaults.standard.value(forKey: UserDetails.userId) as! String){
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longImageVideoPressed))
                cell.addGestureRecognizer(longPressRecognizer)
            }
            
            if let convertedDate = convertDate(from: sourceTimeZone, to: TimeZone.current, dateString: dateString!, format: format) {
                //                print("Converted Date: \(convertedDate)")
                let time = getRequiredFormat(dateStrInTwentyFourHourFomat: convertedDate)
                let newDate = checkDate(givenDate: time!)
                cell.dateLbl.text = newDate
                
            } else {
                print("Failed to convert date.")
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.commentsArray[indexPath.row]
        if (data.commenttype ?? "" ) == "image"{
            let VC = self.storyboard?.instantiateViewController(identifier: "ImageviewPreviewViewController") as! ImageviewPreviewViewController
            if (data.isLocalStore ?? false){
                VC.selectedData = data.isLocalImageData ?? Data()
                if !(data.comment ?? "").isEmpty{
                    VC.selectedImageComment = data.comment ?? ""
                }
            }else{
                let stComment = self.commentsArray[indexPath.row].comment ?? ""
                let arrComment = stComment.components(separatedBy: "--")
                if !arrComment.isEmpty{
                    VC.selectedImageUrl = arrComment[0]
                }
                if arrComment.count > 1{
                    VC.selectedImageComment = arrComment[1]
                }
            }
            VC.modalPresentationStyle = .fullScreen
            self.present(VC, animated: true)
        }
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
        if commentTV.text != "Comment..."
        {
            if editCommentIndex >= 0{
                print("edit")
                self.updatesAPICall()
            }else{
                print("new")
                if !(commentTV.text ?? "").isEmpty{
                    let postparams = PostCommentModel(assigneeEmployeeID: Int(assignEmpID), employeeID: Int(empID), comment: commentTV.text, commenttype: "text", assigneeid: postid)
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
                            let newcomment =  CommentsData(id: "0", assigneeEmployeeID: self.assignEmpID, createdAt: createdAt, comment: self.commentTV.text, employeeID: self.empID, createdBy: self.createdBy, commenttype: "text",isLocalStore: true, isLocalImageData: nil)
                            self.commentsArray.append(newcomment)
                            //                    print(self.commentsArray.count)
                            self.commentTB.reloadData()
                            self.commentTV.text = ""
                            self.commentTV.resignFirstResponder()
                            self.tableviewBottomScroll()
                            
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
        
    }
    
    
    func updatesAPICall(){
        if editCommentIndex >= 0{
            let dataComment = commentsArray[editCommentIndex]
            let postparams = UpdateCommentRequestModel(id: dataComment.id, comment: (commentTV.text ?? "") == "Comment..." ? "" : (commentTV.text ?? ""))
            APIModel.putRequest(strURL: BASEURL + CREATEPOSTAPI as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { result in
                
                var dataOfComment = self.commentsArray[self.editCommentIndex]
                dataOfComment.comment = (self.commentTV.text ?? "") == "Comment..." ? "" : (self.commentTV.text ?? "")
                self.commentsArray[self.editCommentIndex] = dataOfComment
                self.commentTV.resignFirstResponder()
                self.commentTB.reloadData()
                self.commentTV.text = ""
                
            } failureHandler: { error in
                print(error)
            }
        }
    }
    
    func deleteAPICall(){
        if editCommentIndex >= 0{
            let dataComment = commentsArray[editCommentIndex]
            let postparams = DeleteCommentRequestModel(id: dataComment.id ?? "", postID: postid, taskCreatedBy: (UserDefaults.standard.value(forKey: UserDetails.userId) as! String))
            //            print(postparams)
            APIModel.deleteRequest(strURL: BASEURL + CREATEPOSTAPI + "?id=\(dataComment.id ?? "")&assignee_id=\(postid)" as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { result in
                self.commentsArray.remove(at: self.editCommentIndex)
                self.commentTB.reloadData()
            } failureHandler: { error in
                print(error)
            }
        }
    }
    
    func updateTableContentInset() {
        let numRows = self.commentTB.numberOfRows(inSection: 0)
        var contentInsetTop = self.commentTB.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.commentTB.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
                break
            }
        }
        self.commentTB.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
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

extension CommentsViewController:delegateImageAndVideoComment{
    func delegate_VideoUploadComment(selectedUrl: URL, stDesc: String) {
        var stComment = ""
        if !stDesc.isEmpty{
            stComment = "\(selectedUrl)--\(stDesc)"
        }else{
            stComment = "\(selectedUrl)"
        }
        let destinationTime = TimeZone(identifier: "America/Los_Angeles")!
        // 2023-06-13 14:21:33
        let format = "yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let today = getcommentTimeFormat(dateStrInTwentyFourHourFomat: dateFormatter.string(from: Date()))
        let createdAt = convertDate(from: TimeZone.current, to: destinationTime, dateString: today!, format: format)
        let newcomment =  CommentsData(id: "0", assigneeEmployeeID: self.assignEmpID, createdAt: createdAt, comment: stComment, employeeID: self.empID, createdBy: self.createdBy, commenttype: "video",isLocalStore: true, isLocalImageData: nil)
        self.commentsArray.append(newcomment)
        self.commentTB.reloadData()
        self.tableviewBottomScroll()
    }
    
    
    func delegate_ImageUploadComment(selectedData: Data, stDesc: String) {
        //        self.postCommentImage = selectedImage
        let destinationTime = TimeZone(identifier: "America/Los_Angeles")!
        // 2023-06-13 14:21:33
        //        var stComment = ""
        //        if !stDesc.isEmpty{
        //            stComment = "test--\(stDesc)"
        //        }
        
        let format = "yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let today = getcommentTimeFormat(dateStrInTwentyFourHourFomat: dateFormatter.string(from: Date()))
        let createdAt = convertDate(from: TimeZone.current, to: destinationTime, dateString: today!, format: format)
        let newcomment =  CommentsData(id: "0", assigneeEmployeeID: self.assignEmpID, createdAt: createdAt, comment: stDesc, employeeID: self.empID, createdBy: self.createdBy, commenttype: "image",isLocalStore: true, isLocalImageData: selectedData)
        self.commentsArray.append(newcomment)
        self.commentTB.reloadData()
        self.tableviewBottomScroll()
    }
    
    
    func readMsgAPICall(task: String, empid: String, assignID : String)
    {
        let queryItems = ["task_created_by" : task,
                          "employee_id" : empid,
                          "assignee_employee_id" : assignID]
        
        APIModel.patchRequestWithQuiry(strURL: "", params: queryItems, postHeaders: headers as NSDictionary) { jsonResult in
            print(jsonResult)
        } failure: { error in
        }
    }
    
}
