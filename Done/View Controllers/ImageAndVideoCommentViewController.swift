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

class ImageAndVideoCommentViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var imageviewSelectedImage: UIImageView!
    @IBOutlet weak var viewBackBG: UIView!
    @IBOutlet weak var constraintTxtCommentBottom: NSLayoutConstraint!
    @IBOutlet weak var viewVideo: UIView!
    
    //MARK: - Variable
    var selectedImage:UIImage?
    var selectedVideoURL:URL?
    var player: AVPlayer?
    var postPeopleSelected: TagPeople?
    var postid = ""
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CommentsVM.shared.controller = self
        self.imageviewSelectedImage.image = selectedImage ?? UIImage()
        txtComment.layer.cornerRadius = txtComment.bounds.height / 2
        let paddingView: UIView = UIView(frame: CGRect(x: 5, y: 5, width: 5, height: 20))
        txtComment.leftView = paddingView
        txtComment.leftViewMode = .always
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
//            playerLayer.videoGravity = .resizeAspectFill
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
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        IQKeyboardManager.shared.enable = true
        player = nil
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
            constraintTxtCommentBottom.constant = bottomPadding
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
//        print(postPeopleSelected)
        if selectedVideoURL != nil{
            CommentsVM.shared.uploadVideo(fileVideo: selectedVideoURL!,selectedPeople: postPeopleSelected!,postID: postid,stComment: txtComment.text!)
        }else{
            CommentsVM.shared.uploadImage(UploadImage: selectedImage ?? UIImage(),selectedPeople: postPeopleSelected!,postID: postid,stComment: txtComment.text!)
        }
       
        
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
