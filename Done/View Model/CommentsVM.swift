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
    
    func uploadImage(UploadImage:UIImage,stOrderAssigneeEmployeeID:String,employeeID:String,postID:String,stComment:String, taskId: String){
        KRProgressHUD.show()
//        DispatchQueue.global(qos: .background).async {
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
                    self?.addCommentsAPICall(str: awsS3Url, stOrderAssigneeEmployeeID:stOrderAssigneeEmployeeID,employeeID:employeeID, postID: postID, stComment: stComment,commentType: "image", taskId: taskId)
                } else {
                    print("\(String(describing: error?.localizedDescription))")
                    self?.controller?.showToast(message: error!.localizedDescription)
                }
            }
//        }
    }
    
    func uploadVideo(fileVideo:URL,stOrderAssigneeEmployeeID:String,employeeID:String,postID:String,stComment:String, taskId: String){
        KRProgressHUD.show()
//        DispatchQueue.global(qos: .background).async {
            self.compressVideo(videoURL: fileVideo) { videoURL, error in
                if videoURL != nil{
                    //                    KRProgressHUD.show()
                    AWSS3Manager.shared.uploadVideo(videoUrl: videoURL!, progress: { [weak self] (progress) in
                        guard let strongSelf = self else { return }
                    }) { [weak self] (uploadedFileUrl, error) in
                        //                        KRProgressHUD.dismiss()
                        guard let strongSelf = self else { return }
                        if let awsS3Url = uploadedFileUrl as? String {
                            //                print("Uploaded file url: " + awsS3Url)
                            let awsS3Url = SERVERURL + awsS3Url
                            print("upload image url --",awsS3Url)
                            self?.addCommentsAPICall(str: awsS3Url, stOrderAssigneeEmployeeID:stOrderAssigneeEmployeeID,employeeID:employeeID, postID: postID, stComment: stComment,commentType: "video", taskId: taskId)
                        } else {
                            print("\(String(describing: error?.localizedDescription))")
                            self?.controller?.showToast(message: error!.localizedDescription)
                        }
                    }
                }
            }
//        }
    }
    
    func addCommentsAPICall(str : String,stOrderAssigneeEmployeeID:String,employeeID:String,postID:String,stComment:String,commentType:String, taskId : String){
        let userID = UserDefaults.standard.string(forKey: UserDetails.userId)
        var stCommentFinal = ""
        if stComment.isEmpty{
            stCommentFinal = str
        }else{
            stCommentFinal = str + "--\(stComment)"
        }
        //        let postparams = PostMediaCommentModel(assigneeEmployeeID: Int(stOrderAssigneeEmployeeID), employeeID: Int(employeeID), comment: stCommentFinal, commenttype: commentType, assigneeid: postID, taskCreatedBy: userID)
        let postparams = PostMediaCommentModel(employeeID: employeeID, comment: stCommentFinal, commenttype: commentType, orderassigneeid: postID, taskCreatedBy: taskId)
        print("Request parameter==",postparams)
        //            print("This is run on the background queue")
        APIModel.backGroundPostRequest(strURL: BASEURL + CREATEPOSTAPI as NSString, postParams: postparams, postHeaders: headers as NSDictionary) { jsonResult in
            KRProgressHUD.dismiss()
            self.controller?.navigationController?.popViewController(animated: true)
            print("background post comment==\(String(data: jsonResult as! Data, encoding: .utf8))")
            //            self.controller?.navigationController?.popViewController(animated: true)
        } failureHandler: { error in
            print(error)
        }
        DispatchQueue.main.async {
            print("This is run on the main queue, after the previous code in outer block")
        }
    }
    
    func compressVideo(videoURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        let data = NSData(contentsOf: videoURL as URL)!
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        let outPutPath = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.path) {  ///(fileURL) {
            //            var complete : ALAssetsLibraryWriteVideoCompletionBlock = {reason in print("reason \(reason)")}
            //            UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path as String, nil, nil, nil)
            //            UserDefaults.standard.set(videoURL.path, forKey: "originalVideoPath")
        } else {
            print("the file must be bad!")
        }
        //        print("Original Path", videoURL.path)
        DispatchQueue.global(qos: .background).async { [self] in
            compressVideo(inputURL: videoURL, outputURL: outPutPath) { (resulstCompressedURL, error) in
                if let error = error {
                    print("Failed to compress video: \(error.localizedDescription)")
                    completion(nil, error)
                } else if let compressedURL = resulstCompressedURL {
                    //                    print("Video compressed successfully. Compressed video URL: \(compressedURL)")
                    //                    UISaveVideoAtPathToSavedPhotosAlbum(compressedURL.path,nil,nil, nil)
                    //                    UserDefaults.standard.set(videoURL, forKey: "originalVideo")
                    //                    UserDefaults.standard.set(compressedURL.path, forKey: "compressedVideoPath")
                    //                    print(compressedURL.path)
                    completion(compressedURL, nil)
                    guard let compressedData = NSData(contentsOf: compressedURL) else {
                        return
                    }
                    print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                    //                    self.dlete(dele: url)
                }
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, completion: @escaping (URL?, Error?) -> Void) {
        print("Video compressed Started")
        let asset = AVAsset(url: inputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(nil, NSError(domain: "com.example.compressvideo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession"]))
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL, nil)
            case .failed:
                completion(nil, exportSession.error)
            case .cancelled:
                completion(nil, NSError(domain: "com.example.compressvideo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Video compression cancelled"]))
            default:
                break
            }
        }
    }
    
    
}
