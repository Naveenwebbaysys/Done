
//
//  VideoViewController.swift
//  Done
//
//  Created by Mac on 01/06/23.
//

import UIKit
import AVFoundation
import AWSS3
import AWSCore
import KRProgressHUD
import AVKit
import MobileCoreServices
import SwiftyCam
import Photos
import IQKeyboardManagerSwift
@available(iOS 16.0, *)
class VideoViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    var timeout = 0
    var postURl = ""
    var videoTimer : Timer?
    public weak var delegate: SwiftyCamButtonDelegate?
    @IBOutlet weak var sutterBtn : SwiftyCamButton!
    @IBOutlet weak var cameraImgVW :  UIImageView!
    
    private var timerLabl : UILabel = {
        let t = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        t.textColor = .red
        t.text = "00:00"
        return t
    }()
    
    private var cameraBtn : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        //        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 30
        button.setImage(UIImage(named: "Camera_icon"), for: .normal)
        return button
    }()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(timerLabl)
        //        view.addSubview(cameraBtn)
        imagePicker.videoMaximumDuration = TimeInterval(30.0)
        cameraDelegate = self
        sutterBtn.delegate = self
        maximumVideoDuration = 30.0
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        chekCameraPermissions()
        //        chekMicroPhonePermissions()
        cameraImgVW.image = (UIImage(named: "video_iCon"))
        super.viewWillAppear(animated)
        timerLabl.text = "00:00"
        timeout = 0
        //        self.sutterBtn.setImage(UIImage(named: "video_iCon"), for: .normal)
        //        self.sutterBtn.tag = 0
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.isNavigationBarHidden = true
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //        sutterBtn.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 180)
        cameraBtn.center = CGPoint(x: 40, y: view.frame.size.height - 180)
        timerLabl.center = CGPoint(x: sutterBtn.frame.maxX + 100 , y: sutterBtn.frame.midY)
    }
    
    
    
    @IBAction func sutterBtnaction(){
        if sutterBtn.tag == 0
        {
            self.sutterBtn.setImage(UIImage(named: "videoerec_icon"), for: .normal)
            sutterBtn.tag = 1
            startVideoRecording()
        }
        else
        {
            self.sutterBtn.setImage(UIImage(named: "video_iCon"), for: .normal)
            sutterBtn.tag = 0
            stopVideoRecording()
        }
    }
    
    @objc func prozessTimer() {
        if timeout != 30 {
            timeout += 1
        } else {
            stopVideoTimer()
            stopVideoRecording()
        }
        timerLabl.text = "00:" + "\(timeFormatted(timeout))"
        print("This is a second ", timeout)
    }
    
    func stopVideoTimer ()
    {
        videoTimer?.invalidate()
        videoTimer = nil
    }
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 30
        //            let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d", seconds)
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        cameraImgVW.image = (UIImage(named: "videoerec_icon"))
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
        videoTimer = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(prozessTimer), userInfo: nil, repeats: true)
    }
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        // Called if a SwiftyCamButton ends a long press gesture
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
        cameraImgVW.image = (UIImage(named: "video_iCon"))
        stopVideoTimer()
        //        UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
        //        print(url.path)
        let data = NSData(contentsOf: url as URL)!
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        let outPutPath = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {  ///(fileURL) {
            //            var complete : ALAssetsLibraryWriteVideoCompletionBlock = {reason in print("reason \(reason)")}
            UISaveVideoAtPathToSavedPhotosAlbum(url.path as String, nil, nil, nil)
            UserDefaults.standard.set(url.path, forKey: "originalVideoPath")
        } else {
            print("the file must be bad!")
        }
        print("Original Path", url.path)
        DispatchQueue.global(qos: .background).async { [self] in
            compressVideo(inputURL: url, outputURL: outPutPath) { (resulstCompressedURL, error) in
                if let error = error {
                    print("Failed to compress video: \(error.localizedDescription)")
                } else if let compressedURL = resulstCompressedURL {
                    print("Video compressed successfully. Compressed video URL: \(compressedURL)")
                    UISaveVideoAtPathToSavedPhotosAlbum(compressedURL.path,nil,nil, nil)
                    UserDefaults.standard.set(url, forKey: "originalVideo")
                    UserDefaults.standard.set(compressedURL.path, forKey: "compressedVideoPath")
                    print(compressedURL.path)
                    guard let compressedData = NSData(contentsOf: compressedURL) else {
                        return
                    }
                    print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
//                    self.dlete(dele: url)
                }
            }
        }
        DispatchQueue.main.async {
            let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    func savingCallBack(video: NSString, didFinishSavingWithError error:NSError, contextInfo:UnsafeMutableRawPointer){
        print("the file has been saved sucessfully")
//        dlete(dele: video as String)
    }
    
    func deleteVideoFromSavedPhotosAlbum(atPath path: String) {
        PHPhotoLibrary.shared().performChanges({
            if let asset = PHAsset.fetchAssets(withALAssetURLs: [URL(fileURLWithPath: path)], options: nil).firstObject {
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }
        }, completionHandler: { success, error in
            if success {
                print("Video deleted successfully.")
            } else {
                print("Failed to delete video: \(error?.localizedDescription ?? "")")
            }
        })
    }
    
}

@available(iOS 16.0, *)
extension VideoViewController : AVCapturePhotoCaptureDelegate
{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        let  imageview = UIImageView(image: image)
        imageview.contentMode = .scaleAspectFill
        imageview.frame = view.bounds
        view.addSubview(imageview)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Recording started
        print("Recording started")
    }
}


@available(iOS 16.0, *)
extension VideoViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    @objc func video(_ videoPath: String,didFinishSavingWithError error: Error?,contextInfo info: AnyObject
    ) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        
        present(alertController, animated: true)
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
    
    func compressVideo1(inputURL: URL, outputURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: inputURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                completion(outputURL)
                print("Compressed video", outputURL)
                guard let compressedData = NSData(contentsOf: outputURL) else {return}
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
            } else {
                completion(nil)
                print("Compression Failed")
            }
        }
    }

    func deleteVideoFromAlbum(videoURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            if let asset = self.fetchAssetForVideoURL(videoURL) {
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }
        }, completionHandler: { success, error in
            if success {
                print("Video deleted successfully.")
            } else {
                print("Error deleting video: \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    func fetchAssetForVideoURL(_ videoURL: URL) -> PHAsset? {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        let fetchResult = PHAsset.fetchAssets(with: options)
        var asset1: PHAsset?
        fetchResult.enumerateObjects { (object, _, _) in
            if let asset = object as? PHAsset,
               let assetURL = asset.value(forKey: "filename") as? String,
               assetURL == videoURL.lastPathComponent {
                asset1 = asset
                return
            }
        }
        return asset1
    }
    
    func deleteVideoFromAlbum(videoURL: URL, albumName: String) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        PHPhotoLibrary.shared().performChanges({
            if let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil).firstObject {
                let assetToDelete = fetchResult.objects(at: IndexSet(integer: 0))
                PHAssetChangeRequest.deleteAssets(assetToDelete as NSFastEnumeration)
            }
        }) { success, error in
            if success {
                print("Video deleted successfully.")
            } else {
                print("Error deleting video: \(String(describing: error))")
            }
        }
    }
    
    
    func dlete (dele : URL)
    {
        DispatchQueue.global(qos: .background).async{
            let filemgr = FileManager.default
            if filemgr.fileExists(atPath: dele.path) {
                do {
                    try filemgr.removeItem(at: dele)
                    print("Original Video deleted successfully.")
                } catch _ {
                    print("Error deleting video")
                }
            }
        }
    }
}



