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

class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
   
    var session : AVCaptureSession?
    let output = AVCapturePhotoOutput()
    var currentCamera: AVCaptureDevice?
    var movieFileOutput = AVCaptureMovieFileOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    let storkeLayer = CAShapeLayer()
    var isUsingFrontCamera = false
    var postURl = ""
    
    private var sutterBtn : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
//        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 45
        return button
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
//        chekCameraPermissions()
//        chekMicroPhonePermissions()
        view.layer.addSublayer(previewLayer)
        previewLayer.backgroundColor = UIColor.black.cgColor
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress))
        self.sutterBtn.addGestureRecognizer(longPressGesture)
        self.sutterBtn.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        self.sutterBtn.tag = 0
      
        self.sutterBtn.setImage(UIImage(named: "video_iCon"), for: .normal)
        cameraBtn.addTarget(self, action: #selector(cameraBrnAction), for: .touchUpInside)
        storkeLayer.lineWidth = 0
        currentCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        view.addSubview(sutterBtn)
        //        view.addSubview(cameraBtn)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.chekCameraPermissions()
        
        defultCameraSetup()
 
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        sutterBtn.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 180)
        cameraBtn.center = CGPoint(x: 40, y: view.frame.size.height - 180)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        storkeLayer.lineWidth = 0
    }
    
    @objc func didTapShutterBtn ()
    {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
        print("Photo action clicked")
    }
    
    
    private  func chekCameraPermissions()
    {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {self.setupCamere()}
                
            }
        case .restricted:
            askAudioPermissionsAgain()
            break
        case .denied:
            askAudioPermissionsAgain()
            break
        case .authorized:
            self.setupCamere()
        @unknown default:
            break
        }
        
    }
    private  func chekMicroPhonePermissions()
    {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            //            AVCaptureDevice.requestAccess(for: .audio) { granted in
            //                guard granted else {
            //                    return
            //                }
            //                DispatchQueue.main.async {self.setupCamere()}
            //            }
            print("Microphone access notDetermined")
            //            askAudioPermissionsAgain()
        case .restricted:
            print("Microphone access restricted")
            break
        case .denied:
            print("Microphone access denied")
            askAudioPermissionsAgain()
            break
        case .authorized:
            self.setupCamere()
            print("Microphone access granted")
        @unknown default:
            print("Unknown Microphone permission status")
            break
        }
        
    }
    

    
    func askAudioPermissionsAgain(){
        let alert = UIAlertController(
            title: "We were unable to access your Microphone. Sorry!",
            message: "You can enable access in Privacy Settings",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.askAudioPermissionsAgain()
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        self.present(alert, animated: true)
        
    }
    
    func askCameraPermissionsAgain(){
        let alert = UIAlertController(
            title: "We were unable to access your Camera. Sorry!",
            message: "You can enable access in Privacy Settings",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.askCameraPermissionsAgain()
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        self.present(alert, animated: true)
        
    }
    
    private func setupCamere()
    {
        //        chekMicroPhonePermissions()
        let session  = AVCaptureSession()
        
        
        if let device = currentCamera{
            do {
                
                let input =  try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                // Configure audio settings
                if let audioConnection = movieFileOutput.connection(with: .audio) {
                    if audioConnection.isEnabled {
                        // Audio is enabled
                        print("Audio is enabled.")
                    } else {
                        // Enable audio
                        audioConnection.isEnabled = true
                        print("Audio is now enabled.")
                    }
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                DispatchQueue.global(qos: .default).async {
                    session.startRunning()
                }
                //                DispatchQueue.global(qos: .background).async {
                
                //                }
                self.session = session
            }
            catch  {
                print(error)
            }
        }
        
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                
                if session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                } else {
                    print("Unable to add audio input to capture session.")
                }
            } catch {
                print("Error setting up audio input: \(error.localizedDescription)")
            }
        } else {
            print("No audio device found.")
        }
    }
    
    @objc func cameraBrnAction ()
    {
        if isUsingFrontCamera {
            currentCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        } else {
            currentCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        }
        
        isUsingFrontCamera = !isUsingFrontCamera
    }
    
    @objc func recordVideo() {
        chekCameraPermissions()
        chekMicroPhonePermissions()
        if self.sutterBtn.tag == 0
        {
            self.sutterBtn.tag = 1
            
            self.sutterBtn.setImage(UIImage(named: "videoerec_icon"), for: .normal)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let filePath = documentsURL.appendingPathComponent("Done.mp4")
            if FileManager.default.fileExists(atPath: filePath.absoluteString) {
                do {
                    try FileManager.default.removeItem(at: filePath)
                }
                catch {
                    // exception while deleting old cached file
                    // ignore error if any
                }
            }
            session!.addOutput(movieFileOutput)
            movieFileOutput.startRecording(to: filePath, recordingDelegate: self)
        }
        else
        {
            self.sutterBtn.tag = 0

            self.sutterBtn.setImage(UIImage(named: "video_iCon"), for: .normal)
            movieFileOutput.stopRecording()
        }
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            debugPrint("long press started")
            sutterBtn.backgroundColor = UIColor.yellow
            sutterBtn.frame.size = CGSize(width: 110, height: 110)
            sutterBtn.cornerRadius = 55
            storkeLayer.fillColor = UIColor.clear.cgColor
            storkeLayer.strokeColor = UIColor.darkGray.cgColor
            storkeLayer.lineWidth = 10
            
            // Create a rounded rect path using button's bounds.
            storkeLayer.path = CGPath.init(roundedRect: sutterBtn.bounds, cornerWidth: 55, cornerHeight: 55, transform: nil) // same path like the empty one ...
            // Add layer to the button
            sutterBtn.layer.addSublayer(storkeLayer)
            
            // Create animation layer and add it to the stroke layer.
            animation.fromValue = CGFloat(0.0)
            animation.toValue = CGFloat(1.0)
            animation.duration = 30
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            storkeLayer.add(animation, forKey: "cornerRadiusAnimation")
            
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let filePath = documentsURL.appendingPathComponent("Done.mp4")
            if FileManager.default.fileExists(atPath: filePath.absoluteString) {
                do {
                    try FileManager.default.removeItem(at: filePath)
                }
                catch {
                    // exception while deleting old cached file
                    // ignore error if any
                }
            }
            session!.addOutput(movieFileOutput)
            movieFileOutput.startRecording(to: filePath, recordingDelegate: self)
        }
        else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            debugPrint("longpress ended")
            storkeLayer.lineWidth = 0
            sutterBtn.backgroundColor = UIColor.white
            sutterBtn.frame.size = CGSize(width: 90, height: 90)
            sutterBtn.cornerRadius = 45
            movieFileOutput.stopRecording()
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
        session?.stopRunning()
        let  imageview = UIImageView(image: image)
        imageview.contentMode = .scaleAspectFill
        imageview.frame = view.bounds
        view.addSubview(imageview)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let error = error {
            print("Recording finished with error: \(error.localizedDescription)")
        } else {
            print("Recording finished: \(outputFileURL)")
            print("Recording finished: \(outputFileURL.path)")
            print("recorded duration:",output.recordedDuration)
            if error == nil {
                UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
                let videoPath = outputFileURL.path
                //                uploadVideoToS3Server(filePath: videoPath)
                UserDefaults.standard.set(videoPath, forKey: "videoPath")
                self.tabBarController?.selectedIndex = 2
            }
        }
    }
}




extension VideoViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    func defultCameraSetup()
    {
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.rear) {
                imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            let screenSize: CGSize = imagePicker.view.safeAreaLayoutGuide.layoutFrame.size
            let ratio: CGFloat = 4.0 / 4.0
            let cameraHeight: CGFloat = screenSize.width * ratio
            let scale: CGFloat = (screenSize.height + 80) / cameraHeight
            imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale)
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
        UserDefaults.standard.set(url.path, forKey: "videoPath")
        self.tabBarController?.selectedIndex = 2
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
    
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            askCameraPermissionsAgain()
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                } else {
                    print("Permission denied")
                }
            }
        @unknown default:
            print("Unknown Camera permission status")
            break
        }
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
}
