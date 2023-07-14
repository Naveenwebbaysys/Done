//
//  TaskProofView.swift
//  Done
//
//  Created by Sagar on 12/07/23.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import KRProgressHUD

protocol taskProofviewDelegate{
    func taskProofDone(index:Int)
}
class TaskProofView: UIView, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    //MARK: - Outlet
    @IBOutlet var viewBG: UIView!
    @IBOutlet weak var txtviewDesc: UITextView!
//    @IBOutlet weak var lblUploadedName: UILabel!
    @IBOutlet weak var constraintViewCenter: NSLayoutConstraint!
    @IBOutlet weak var collectionviewImageUpload: UICollectionView!
    
    //MARK: - Variable
    let obj_AppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var arrMediaUpload: [String] = ["+"]
    var postID: Int = 0
    var employeeID: Int = 0
    var index: Int = 0
    var taskStatus: String = ""
    var delegate: taskProofviewDelegate?
    var orderAssigneID: Int = 0
    var createdBy: String = ""
    
    //MARK: - UIView
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(info taskStatus: String,postID:Int,employeeID:Int,index:Int,orderAssigneID:Int,createdBy:String) {
        super.init(frame: UIScreen.main.bounds)
        self.postID = postID
        self.employeeID = employeeID
        self.index = index
        self.taskStatus = taskStatus
        self.orderAssigneID = orderAssigneID
        self.createdBy = createdBy
        loadXIB()
    }
    
    fileprivate func loadXIB() {
        self.alpha = 1
        let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?[0] as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(view)
        
        //TOP
        self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0))
        
        //LEADING
        self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0))
        
        //WIDTH
        self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0))
        
        //HEIGHT
        self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0))
        
        self.layoutIfNeeded()
        
        self.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        
        UIApplication.shared.currentWindow?.addSubview(self)
        txtviewDesc.text = "Proof Description"
        txtviewDesc.textColor = UIColor.lightGray
        
        collectionviewImageUpload.delegate = self
        collectionviewImageUpload.dataSource = self
        collectionviewImageUpload.register(UINib(nibName: "ProofMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProofMediaCollectionViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        viewBG.alpha = 0;
        var sFrame: CGRect = viewBG.frame;
        sFrame.origin.y = -(viewBG.frame.height)
        viewBG.frame = sFrame;
        
        let velocity: CGFloat = 10;
        let duration: CGFloat = 0.8
        let damping: CGFloat = 0.7
        
        UIView.animate(withDuration: TimeInterval(duration), delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIView.AnimationOptions.beginFromCurrentState, animations: { self.viewBG.alpha = 1; self.viewBG.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2); }, completion: nil)
        
    }
    
    //MARK: - KeyBoard Handler
    @objc func keyboardWillShow(notification: Notification) {
//        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
//            print("Notification: Keyboard will show")
////            var bottomPadding:CGFloat = 0
////            if #available(iOS 13.0, *) {
////                let window = UIApplication.shared.windows.first
////                bottomPadding = window?.safeAreaInsets.bottom ?? 0
////            }
//
//        }
        constraintViewCenter.constant = -25
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        constraintViewCenter.constant = 0
    }
    
    
    //MARK: - Other
    func CloseView(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: UIView.KeyframeAnimationOptions.beginFromCurrentState, animations: {
            var frame = self.viewBG.frame
            frame.origin.y = self.frame.maxY + frame.height
            self.viewBG.frame = frame
        }, completion: { (finished) in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: { self.alpha = 0 }, completion:{ (finished) in self.removeFromSuperview() })
        })
    }
    
    func uploadVideo(fileVideo:URL){
        KRProgressHUD.show()
        CommentsVM.shared.compressVideo(videoURL: fileVideo) { videoURL, error in
            if videoURL != nil{
                //                    KRProgressHUD.show()
                AWSS3Manager.shared.uploadVideo(videoUrl: videoURL!, progress: { [weak self] (progress) in
                    guard let strongSelf = self else { return }
                }) { [weak self] (uploadedFileUrl, error) in
                    KRProgressHUD.dismiss()
                    guard let strongSelf = self else { return }
                    if let awsS3Url = uploadedFileUrl as? String {
                        let awsS3Url = SERVERURL + awsS3Url
//                        self?.arrMediaUpload.insert(awsS3Url, at: 0)
                        self?.arrMediaUpload = [awsS3Url]
                        self?.collectionviewImageUpload.reloadData()
                    } else {
                        print("\(String(describing: error?.localizedDescription))")
                        let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
                        rootVC?.showToast(message: error!.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    func uploadImageAWS(UploadImage:UIImage){
        KRProgressHUD.show()
        AWSS3Manager.shared.uploadImage(image: UploadImage, progress: { [weak self] (progress) in
            guard let strongSelf = self else { return }
        }) { [weak self] (uploadedFileUrl, error) in
            KRProgressHUD.dismiss()
            guard let strongSelf = self else { return }
            if let awsS3Url = uploadedFileUrl as? String {
                print("Uploaded file url: " + awsS3Url)
                let awsS3Url = SERVERURL + awsS3Url
//                self?.arrMediaUpload.insert(awsS3Url, at: 0)
                self?.arrMediaUpload = [awsS3Url]
                self?.collectionviewImageUpload.reloadData()
                print("upload image url --",awsS3Url)
            } else {
                print("\(String(describing: error?.localizedDescription))")
                let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
                rootVC?.showToast(message: error!.localizedDescription)
            }
        }
    }
    
//    func setFileName(){
//        for (index,stUrl) in self.arrMediaUpload.enumerated(){
//            let theURL = URL(string: stUrl)  //use your URL
//            if index == 0{
//                self.lblUploadedName.text = theURL?.lastPathComponent ?? ""
//            }else{
//                self.lblUploadedName.text! += theURL?.lastPathComponent ?? ""
//            }
//        }
//
//    }
    
    func showToast(message:String) {
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.frame.height - 125, width: self.frame.width - 50, height: 35))
        toastLabel.backgroundColor = UIColor(named: "app_color")
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 13.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 18
        toastLabel.clipsToBounds = true
        self.addSubview(toastLabel)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            UIView.animate(withDuration: 2.0, delay: 0.2, options: .curveEaseOut, animations:
                            {
                toastLabel.alpha = 0.0
                
            }) { (isCompleted) in
                toastLabel.removeFromSuperview()
            }
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
    
    //MARK: - UIButton Action
    func btnVideoImageUploadAction() {
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
                        let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
                        rootVC?.present(picker, animated: true)
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
    
    func openPhotos(){
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.mediaTypes = ["public.image","public.movie"]
                picker.delegate = self
                picker.videoMaximumDuration = TimeInterval(30.0)
                picker.allowsEditing = false
                let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
                rootVC?.present(picker, animated: true)
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
                            let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
                            rootVC?.present(picker, animated: true)
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
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
    
        let index = arrMediaUpload.firstIndex(of: "+")  ?? -1
        if index >= 0{
            self.arrMediaUpload.remove(at: index)
        }
        if arrMediaUpload.isEmpty{
            showToast(message: "Please Select media.")
            return
        }
        
        
        KRProgressHUD.show()
        let postparams = UpdateDoneRequestModel(postID: self.postID, employeeID: self.employeeID, taskStatus: self.taskStatus,proofDescription: txtviewDesc.text! == "description" ? "" : txtviewDesc.text!,proofDocument:arrMediaUpload.joined(separator: ","), orderAssigneeID: self.postID)
//        print(postparams)
        APIModel.putRequest(strURL: BASEURL + UPDATEPOSTASDONE as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { result in
            KRProgressHUD.dismiss()
            self.delegate?.taskProofDone(index: self.index)
            self.CloseView()
            
            let stData = self.arrMediaUpload[0]
            var stType = "image"
            if stData.isImageType(){
                stType = "image"
            }else{
                stType = "video"
            }
            CommentsVM.shared.addCommentsAPICall(str: self.arrMediaUpload[0], stOrderAssigneeEmployeeID: "", employeeID: "\(self.employeeID)", postID: "\(self.postID)", stComment: self.txtviewDesc.text! == "description" ? "" : "Proof: \(self.txtviewDesc.text!)", commentType: stType, taskId: self.createdBy)
            
        } failureHandler: { error in
            KRProgressHUD.dismiss()
            self.CloseView()
            let rootVC = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
            rootVC?.showToast(message: error)
        }
        
       
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            print("Selected image ",image)
            self.uploadImageAWS(UploadImage: image)
        }else if let videoUrl = info[.mediaURL] as? URL {
            print("Selected video ",videoUrl)
            self.uploadVideo(fileVideo: videoUrl)
        }else{
            print("Data nooooooooo")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    //MARK: - UICollectionview Delegate and Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrMediaUpload.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProofMediaCollectionViewCell", for: indexPath) as! ProofMediaCollectionViewCell
        let stData = arrMediaUpload[indexPath.row]
        if stData == "+"{
            cell.btnPlay.isHidden = false
            cell.btnPlay.setImage(UIImage(named: "camera_roll_icon"), for: .normal)
            cell.btnPlay.isUserInteractionEnabled = false
        }else{
            if stData.isImageType(){
                cell.btnPlay.isHidden = true
               cell.imageview.sd_setImage(with: URL.init(string: stData), placeholderImage: nil, options: .highPriority) { (imge, error, cache, url) in
                    if error == nil{
                        cell.imageview.image = imge
                    }else{
                     
                    }
                }
            }else{
                cell.btnPlay.isHidden = true
                cell.btnPlay.tag = indexPath.row
    //            cell.btnPlay.addTarget(self, action: #selector(btnVideoPlayAction), for: .touchUpInside)
                DispatchQueue.global(qos: .background).async { [self] in
                    let videoUrl = URL(string: stData)
                    DispatchQueue.main.async {
                        cell.imageview.image = self.getVideoThumbnail(url: videoUrl!)
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        /// 2
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let lay = collectionViewLayout as! UICollectionViewFlowLayout
        let widthPerItem = (collectionView.frame.width / 2) - lay.minimumInteritemSpacing
        
        return CGSize(width: widthPerItem - 1, height: widthPerItem - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stData = arrMediaUpload[indexPath.row]
        if stData == "+"{
            self.btnVideoImageUploadAction()
        }
//        let stData = arrMediaUpload[indexPath.row]
//        if stData.isImageType(){
//            let VC = self.storyboard?.instantiateViewController(identifier: "ImageviewPreviewViewController") as! ImageviewPreviewViewController
//            VC.selectedImageUrl = stData
//            VC.selectedImageComment = ""
//            VC.modalPresentationStyle = .fullScreen
//            self.present(VC, animated: true)
//        }
    }
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
            let touch = touches.first
            if touch?.view != self.viewBG
            {
                CloseView()
                
            }
        }
    
}
