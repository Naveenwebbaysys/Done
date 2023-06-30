//
//  ImageAndVideoCommentViewController.swift
//  Done
//
//  Created by Sagar on 27/06/23.
//

import UIKit
import IQKeyboardManagerSwift
import KRProgressHUD
import AVKit

protocol delegateImageAndVideoComment{
    func delegate_ImageUploadComment(selectedData: Data,stDesc:String)
    func delegate_VideoUploadComment(selectedUrl:URL,stDesc:String)
}


class ImageAndVideoCommentViewController: UIViewController, UITextViewDelegate {
    
    //MARK: - Outlet
//    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var constraintTxtCommentHeight: NSLayoutConstraint!
    @IBOutlet weak var imageviewSelectedImage: UIImageView!
    @IBOutlet weak var viewBackBG: UIView!
    @IBOutlet weak var constraintTxtCommentBottom: NSLayoutConstraint!
    @IBOutlet weak var viewVideo: UIView!
    
    //MARK: - Variable
    var selectedImage:UIImage?
    var selectedVideoURL:URL?
    var player: AVPlayer?
    var postPeopleSelected: PostStatus?
    var postid = ""
    var delegate:delegateImageAndVideoComment?
    var orderAssigneeEmployeeID = ""
    var employeeID = ""
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CommentsVM.shared.controller = self
        self.imageviewSelectedImage.image = selectedImage ?? UIImage()
//        txtComment.layer.cornerRadius = txtComment.bounds.height / 2
//        let paddingView: UIView = UIView(frame: CGRect(x: 5, y: 5, width: 5, height: 20))
//        txtComment.leftView = paddingView
//        txtComment.leftViewMode = .always
        viewBackBG.layer.cornerRadius = viewBackBG.bounds.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        IQKeyboardManager.shared.enable = false
        self.viewVideo.isHidden = true
        if selectedVideoURL != nil{
            self.viewVideo.isHidden = false
            player = AVPlayer()
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            viewVideo.layer.addSublayer(playerLayer)
            
        
            let playerItem = AVPlayerItem(url: selectedVideoURL!)
            player?.replaceCurrentItem(with: playerItem)
            player?.play()

            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main)
            { [weak self] _ in
                self?.player?.seek(to: CMTime.zero)
                self?.player?.play()
            }
        }
       
        commentTV.backgroundColor = .clear
        commentTV.text = "Comment..."
        commentTV.textColor = UIColor.lightGray
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        IQKeyboardManager.shared.enable = true
        if self.player != nil{
            self.player?.pause()
            player = nil
        }
        
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
            constraintTxtCommentBottom.constant = keyboardHeight - bottomPadding
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        constraintTxtCommentBottom.constant = 10
        self.view.layoutIfNeeded()
    }
    
    //MARK: - UIButton Action
    @IBAction func btnSendAction(_ sender: UIButton) {
        if self.player != nil{
            self.player?.pause()
            player = nil
        }
        if selectedVideoURL != nil{
            self.delegate?.delegate_VideoUploadComment(selectedUrl: self.selectedVideoURL!, stDesc: commentTV.text == "Comment..." ? "" : commentTV.text!)
            CommentsVM.shared.uploadVideo(fileVideo: selectedVideoURL!,stOrderAssigneeEmployeeID:self.orderAssigneeEmployeeID,employeeID:self.employeeID,postID: postid,stComment: commentTV.text == "Comment..." ? "" : commentTV.text!)
        }else{
            if self.selectedImage != nil{
                guard let imageData = self.selectedImage!.jpegData(compressionQuality: 0.5) else {
                    let error = NSError(domain:"", code:402, userInfo:[NSLocalizedDescriptionKey: "invalid image"])
                    return
                }
                self.delegate?.delegate_ImageUploadComment(selectedData: imageData, stDesc: commentTV.text == "Comment..." ? "" : commentTV.text!)
                CommentsVM.shared.uploadImage(UploadImage: selectedImage ?? UIImage(),stOrderAssigneeEmployeeID:self.orderAssigneeEmployeeID,employeeID:self.employeeID,postID: postid,stComment: commentTV.text == "Comment..." ? "" : commentTV.text!)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        if self.player != nil{
            self.player?.pause()
            player = nil
        }
        self.navigationController?.popViewController(animated: true)
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
}
