
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

class VideoViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {

    var timeout = 1
    var postURl = ""
    var videoTimer : Timer?
    public weak var delegate: SwiftyCamButtonDelegate?
    @IBOutlet weak var sutterBtn : SwiftyCamButton!

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
        // Do any additional setup after loading the view.
        //        view.backgroundColor = .black

//        view.addSubview(sutterBtn)
        view.addSubview(timerLabl)
        //        view.addSubview(cameraBtn)
        imagePicker.videoMaximumDuration = TimeInterval(30.0)
        cameraDelegate = self
        sutterBtn.delegate = self
        maximumVideoDuration = 30.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        chekCameraPermissions()
//        chekMicroPhonePermissions()
        super.viewWillAppear(animated)
        timerLabl.text = "00:00"
        self.sutterBtn.setImage(UIImage(named: "video_iCon"), for: .normal)
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
        stopVideoTimer()
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
        print(url.path)
        
        let data = NSData(contentsOf: url as URL)!
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        
        let outPutPath = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
        
        DispatchQueue.global(qos: .background).async { [self] in
            compressVideo(inputURL: url, outputURL: outPutPath) { (resulstCompressedURL, error) in
                if let error = error {
                    print("Failed to compress video: \(error.localizedDescription)")
                } else if let compressedURL = resulstCompressedURL {
                    print("Video compressed successfully. Compressed video URL: \(compressedURL)")
                    UISaveVideoAtPathToSavedPhotosAlbum(compressedURL.path,nil,nil, nil)
                    UserDefaults.standard.set(url.path, forKey: "originalVideoPath")
                    UserDefaults.standard.set(url, forKey: "originalVideo")
                    UserDefaults.standard.set(compressedURL.path, forKey: "compressedVideoPath")
                    print(compressedURL.path)
                    
                    guard let compressedData = NSData(contentsOf: compressedURL) else {
                        return
                    }
                    print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                }
            }
        }
                
        DispatchQueue.main.async {
//            self.tabBarController?.selectedIndex = 2
            let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
  
}

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


extension VideoViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func defultCameraSetup()
    {
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.rear) {
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
//                        let screenSize: CGSize = imagePicker.view.safeAreaLayoutGuide.layoutFrame.size
//                        let ratio: CGFloat = 4.0 / 2.0
//                        let cameraHeight: CGFloat = screenSize.width * ratio
//                        let scale: CGFloat = (screenSize.height) / cameraHeight
//            imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale)
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        dismiss(animated: true, completion: nil)
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              // 1
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
              // 2
              UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
        else { return }
        
        // 3
        UISaveVideoAtPathToSavedPhotosAlbum(url.path,nil,nil, nil)
        print(url.path)
        
        let data = NSData(contentsOf: url as URL)!
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        
        let outPutPath = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
        
        DispatchQueue.global(qos: .background).async { [self] in
            compressVideo(inputURL: url, outputURL: outPutPath) { (resulstCompressedURL, error) in
                if let error = error {
                    print("Failed to compress video: \(error.localizedDescription)")
                } else if let compressedURL = resulstCompressedURL {
                    print("Video compressed successfully. Compressed video URL: \(compressedURL)")
                    UISaveVideoAtPathToSavedPhotosAlbum(compressedURL.path,nil,nil, nil)
                    UserDefaults.standard.set(url.path, forKey: "originalVideoPath")
                    UserDefaults.standard.set(url, forKey: "originalVideo")
                    UserDefaults.standard.set(compressedURL.path, forKey: "compressedVideoPath")
                    print(compressedURL.path)
                    
                    guard let compressedData = NSData(contentsOf: compressedURL) else {
                        return
                    }
                    print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
  
                }
            }

        }
                
        DispatchQueue.main.async {
//            self.tabBarController?.selectedIndex = 2
            let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            self.navigationController?.pushViewController(postVC, animated: true)
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        self.tabBarController?.selectedIndex = 0
        
    }
    
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
    
    

    
    
}



