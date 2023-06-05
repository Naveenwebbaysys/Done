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
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 45
        //        button.layer.borderWidth = 5
        //        button.layer.borderColor = UIColor.darkGray.cgColor
        
        //        yourView.layer.borderWidth = 0.0
        return button
    }()
    
    private var cameraBtn : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 30
        button.setImage(UIImage(named: "Camera_icon"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        view.backgroundColor = .black
        chekCameraPermissions()
        chekMicroPhonePermissions()
        view.layer.addSublayer(previewLayer)
        previewLayer.backgroundColor = UIColor.black.cgColor
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress))
        self.sutterBtn.addGestureRecognizer(longPressGesture)
        cameraBtn.addTarget(self, action: #selector(cameraBrnAction), for: .touchUpInside)
        storkeLayer.lineWidth = 0
        currentCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        view.addSubview(sutterBtn)
        view.addSubview(cameraBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.chekCameraPermissions()
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
    
    func checkMicrophonePermissions() -> AVAudioSession.RecordPermission {
        let permissionStatus = AVAudioSession.sharedInstance().recordPermission
        
        switch permissionStatus {
        case .granted:
            print("Microphone access granted")
        case .denied:
            print("Microphone access denied")
        case .undetermined:
            print("Microphone access undetermined")
        @unknown default:
            print("Unknown microphone permission status")
        }
        
        return permissionStatus
    }
    
    func askAudioPermissionsAgain(){
        let alert = UIAlertController(
            title: "We were unable to access your Microphone. Sorry!",
            message: "You can enable access in Privacy Settings",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
                DispatchQueue.global(qos: .background).async {
                    session.startRunning()
                }
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
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
       
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            debugPrint("long press started")
            sutterBtn.backgroundColor = UIColor.yellow
            sutterBtn.frame.size = CGSize(width: 110, height: 110)
            sutterBtn.cornerRadius = 55
            storkeLayer.fillColor = UIColor.clear.cgColor
            storkeLayer.strokeColor = UIColor.darkGray.cgColor
            storkeLayer.lineWidth = 8
            
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
                
                let postVC = self.storyboard?.instantiateViewController(identifier: "PostViewController") as! PostViewController
                postVC.recordVideoURL = videoPath
                self.navigationController?.pushViewController(postVC, animated: true)
            }
        }
    }
}

