//
//  CommentsVM.swift
//  Done
//
//  Created by Sagar on 28/06/23.
//

import UIKit
import KRProgressHUD
import Photos

class CommentsVM: NSObject {
    static let shared = CommentsVM()
    var controller : UIViewController?
    
    func uploadImage(UploadImage:UIImage,selectedPeople:TagPeople,postID:String,stComment:String){
        KRProgressHUD.show()
        AWSS3Manager.shared.uploadImage(image: UploadImage, progress: { [weak self] (progress) in
            guard let strongSelf = self else { return }
        }) { [weak self] (uploadedFileUrl, error) in
            KRProgressHUD.dismiss()
            guard let strongSelf = self else { return }
            if let awsS3Url = uploadedFileUrl as? String {
                print("Uploaded file url: " + awsS3Url)
                let awsS3Url = SERVERURL + awsS3Url
                print("upload image url --",awsS3Url)
                //                self?.createPostAPICall(str: awsS3Url)
                self?.addCommentsAPICall(str: awsS3Url, selectedPeople: selectedPeople, postID: postID, stComment: stComment)
            } else {
                print("\(String(describing: error?.localizedDescription))")
                self?.controller?.showToast(message: error!.localizedDescription)
            }
        }
    }
    
    func uploadVideo(fileVideo:URL,selectedPeople:TagPeople,postID:String,stComment:String){
        let compressURL = self.compressVideo(videoURL: fileVideo)
        KRProgressHUD.show()
        AWSS3Manager.shared.uploadVideo(videoUrl: compressURL, progress: { [weak self] (progress) in
            guard let strongSelf = self else { return }
        }) { [weak self] (uploadedFileUrl, error) in
            KRProgressHUD.dismiss()
            guard let strongSelf = self else { return }
            if let awsS3Url = uploadedFileUrl as? String {
//                print("Uploaded file url: " + awsS3Url)
                let awsS3Url = SERVERURL + awsS3Url
                print("upload image url --",awsS3Url)
                self?.addCommentsAPICall(str: awsS3Url, selectedPeople: selectedPeople, postID: postID, stComment: stComment)
            } else {
                print("\(String(describing: error?.localizedDescription))")
                self?.controller?.showToast(message: error!.localizedDescription)
            }
        }
    }
    
    func addCommentsAPICall(str : String,selectedPeople:TagPeople,postID:String,stComment:String){
        let userID = UserDefaults.standard.string(forKey: UserDetails.userId)
        var stCommentFinal = ""
        if stComment.isEmpty{
            stCommentFinal = str
        }else{
            stCommentFinal = str + "--\(stComment)"
        }
        let postparams = PostMediaCommentModel(assigneeEmployeeID: Int(selectedPeople.orderAssigneeEmployeeID ?? "0"), employeeID: Int(selectedPeople.employeeID ?? "0"), comment: stCommentFinal, commenttype: "image", assigneeid: postID, taskCreatedBy: userID)
//        print("Request parameter==",postparams)
        DispatchQueue.global(qos: .background).async {
//            print("This is run on the background queue")
            APIModel.backGroundPostRequest(strURL: BASEURL + CREATEPOSTAPI as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { jsonResult in
                print(jsonResult)
                self.controller?.navigationController?.popViewController(animated: true)
            } failureHandler: { error in
                print(error)
            }
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
            }
        }
    }
    
    func compressVideo(videoURL: URL) -> URL {
        let data = NSData(contentsOf: videoURL as URL)!
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mov")
        compressVideoHelperMethod(inputURL: videoURL , outputURL: compressedURL) { (exportSession) in
            
        }
        return compressedURL
    }
    
    func compressVideoHelperMethod(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }

}
