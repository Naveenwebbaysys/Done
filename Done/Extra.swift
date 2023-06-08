//
//  Extra.swift
//  Done
//
//  Created by Mac on 07/06/23.
//

import Foundation
import AVFAudio


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
