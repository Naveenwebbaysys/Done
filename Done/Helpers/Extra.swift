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



//                    DispatchQueue.main.async {
//                        let section = 0 // Assuming you have only one section
//                        let lastRow = self.commentTB.numberOfRows(inSection: section)
//                        let lastRowIndexPath = IndexPath(row: lastRow, section: section)
//                        self.commentTB.insertRows(at: [lastRowIndexPath], with: .none)
//
//                        let indexPosition = IndexPath(row: self.commentsArray.count - 1, section: 0)
//                        self.commentTB.scrollToRow(at: indexPosition, at: .bottom, animated: false)
//
//                        //                        let lastRowIndex =  self.commentsArray.count - 1
//                        //                        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: 0)
//                        //                        self.commentTB.reloadData()
//                        //                        let isScrolledToBottom = self.commentTB.contentOffset.y + self.commentTB.frame.size.height >= self.commentTB.contentSize.height
//                        //
//                        //                        if isScrolledToBottom {
//                        //                            self.commentTB.scrollToRow(at: lastRowIndexPath, at: .bottom, animated: true)
//                        //                        }
//
//                    }
