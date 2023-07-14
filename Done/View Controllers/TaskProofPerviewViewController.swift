//
//  TaskProofPerviewViewController.swift
//  Done
//
//  Created by Sagar on 13/07/23.
//

import UIKit
import AVFoundation
import AVKit
import IQKeyboardManagerSwift

class TaskProofPerviewViewController: UIViewController,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {

    //MARK: - Outlet
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var collectionviewProof: UICollectionView!
    @IBOutlet weak var constraintTextviewRason: NSLayoutConstraint!
    @IBOutlet weak var txtviewReason: UITextView!
    
    //MARK: - Variable
    var postID:Int?
    var employeeID:Int?
    var proofDesc : String?
    var proodDoc : String?
    var arrLinks: [String] = [String]()
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionviewProof.register(UINib(nibName: "ProofMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProofMediaCollectionViewCell")
        self.arrLinks = (proodDoc ?? "").components(separatedBy: ",")
        self.collectionviewProof.reloadData()
        
        txtviewReason.text = "Reason..."
        txtviewReason.textColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
            constraintTextviewRason.constant = keyboardHeight - bottomPadding
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        constraintTextviewRason.constant = 10
        self.view.layoutIfNeeded()
    }
    
    //MARK: - Other Methods
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
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
  
    @IBAction func btnDoneAction(_ sender: UIButton) {
    }
    
    @objc func btnVideoPlayAction(_ sender : UIButton){
        let data = self.arrLinks[sender.tag]
        
        let VC = self.storyboard?.instantiateViewController(identifier: "VideoPerviewViewController") as! VideoPerviewViewController
        VC.selectedVideoURL = data
        VC.selectedVideoComment = ""
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true)
        
    }
    
    @IBAction func btnRejectAction(_ sender: UIButton) {
        if txtviewReason.text! == "Reason..."{
            self.showToast(message: "Please enter reason")
            return
        }
        self.setRootVC()
    }
    
    
    @IBAction func btnApproveACtion(_ sender: UIButton) {
        let feedbackVC = storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        feedbackVC.postID = postID
        feedbackVC.employeeID = employeeID
        self.navigationController?.pushViewController(feedbackVC, animated: true)
    }
    
    
    //MARK: - UICollectionview Delegate and Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrLinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProofMediaCollectionViewCell", for: indexPath) as! ProofMediaCollectionViewCell
        let stData = arrLinks[indexPath.row]
        if stData.isImageType(){
            cell.btnPlay.isHidden = true
           cell.imageview.sd_setImage(with: URL.init(string: stData), placeholderImage: nil, options: .highPriority) { (imge, error, cache, url) in
                if error == nil{
                    cell.imageview.image = imge
                }else{
                 
                }
            }
        }else{
            cell.btnPlay.isHidden = false
            cell.btnPlay.tag = indexPath.row
            cell.btnPlay.addTarget(self, action: #selector(btnVideoPlayAction), for: .touchUpInside)
            DispatchQueue.global(qos: .background).async { [self] in
                let videoUrl = URL(string: stData)
                DispatchQueue.main.async {
                    cell.imageview.image = self.getVideoThumbnail(url: videoUrl!)
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
        let stData = arrLinks[indexPath.row]
        if stData.isImageType(){
            let VC = self.storyboard?.instantiateViewController(identifier: "ImageviewPreviewViewController") as! ImageviewPreviewViewController
            VC.selectedImageUrl = stData
            VC.selectedImageComment = ""
            VC.modalPresentationStyle = .fullScreen
            self.present(VC, animated: true)
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
            textView.text = "Reason..."
            textView.textColor = UIColor.lightGray
        }
    }
}
