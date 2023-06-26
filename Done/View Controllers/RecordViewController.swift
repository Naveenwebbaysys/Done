//
//  RecordViewController.swift
//  Done
//
//  Created by Mac on 12/06/23.
//

import UIKit
import SwiftyCam

class RecordViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {

    @IBOutlet weak var captureButton : SwiftyCamButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraDelegate = self
        
        
        captureButton.delegate = self
    }
    
    @IBAction func captureButtonaction(){
        
        if captureButton.tag == 0
        {
            captureButton.tag = 1
            startVideoRecording()
        }
        else
        {
            captureButton.tag = 0
            stopVideoRecording()
        }
        
    }
   
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
         // Called when startVideoRecording() is called
         // Called if a SwiftyCamButton begins a long press gesture
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
         // Called when stopVideoRecording() is called
         // Called if a SwiftyCamButton ends a long press gesture
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
         // Called when stopVideoRecording() is called and the video is finished processing
         // Returns a URL in the temporary directory where video is stored
        
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
    }


}
