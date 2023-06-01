//
//  VideoViewController.swift
//  Done
//
//  Created by Mac on 01/06/23.
//

import UIKit
import AVFoundation


class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        
        
        print("recorded duration:",output.recordedDuration)
        
    }
    
    var session : AVCaptureSession?
    let output = AVCapturePhotoOutput()
    var movieFileOutput = AVCaptureMovieFileOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    private var sutterBtn : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.red.cgColor
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        chekPermissions()
        view.layer.addSublayer(previewLayer)
        previewLayer.backgroundColor = UIColor.orange.cgColor
        view.addSubview(sutterBtn)
//        sutterBtn.addTarget(self, action: #selector(didTapShutterBtn), for: .touchUpInside)
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress))
        self.sutterBtn.addGestureRecognizer(longPressGesture)
    }

    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        sutterBtn.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 180)
    }
    
    @objc func didTapShutterBtn ()
    {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
        print("Photo action clicked")
    }
    
    
   private  func chekPermissions()
    {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.setupCamere()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            self.setupCamere()
        @unknown default:
            break
        }
        
        
    
    }

    
    private func setupCamere()
    {
        let session  = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: .video){
            do {
                let input =  try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(input){
                    session.addInput(input)
                }
                
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                session.startRunning()
                self.session = session
            }
            catch  {
                
                print(error)
            }
        }
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {

        if gestureRecognizer.state == UIGestureRecognizer.State.began {
                debugPrint("long press started")
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
                let filePath = documentsURL.appendingPathComponent("tempMovie.mp4")
                if FileManager.default.fileExists(atPath: filePath.absoluteString) {
                    do {
                        try FileManager.default.removeItem(at: filePath)
                    }
                    catch {
                        // exception while deleting old cached file
                        // ignore error if any
                    }
                }
            movieFileOutput.startRecording(to: filePath, recordingDelegate: self)
            }
        else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
                debugPrint("longpress ended")
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
    
}
