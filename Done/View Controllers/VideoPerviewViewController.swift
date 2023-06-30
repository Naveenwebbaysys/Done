//
//  VideoPerviewViewController.swift
//  Done
//
//  Created by Sagar on 30/06/23.
//

import UIKit
import AVKit

class VideoPerviewViewController: UIViewController {
   
    //MARK: - Outlet
    @IBOutlet weak var viewVideoPlyer: UIView!
    @IBOutlet weak var lblComment: UILabel!
    
    //MARK: - Variable
    var player: AVPlayer?
    var selectedVideoURL:String?
    var selectedVideoComment:String?
    
    //MARK: - view Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        lblComment.isHidden = true
        player = AVPlayer(url: URL.init(string: selectedVideoURL ?? "")!)
        player?.rate = 1 //auto play
        let playerFrame = CGRect(x: 0, y: 0, width: viewVideoPlyer.bounds.width, height: viewVideoPlyer.bounds.height)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = playerFrame
        playerViewController.showsPlaybackControls = true
        
        addChild(playerViewController)
        viewVideoPlyer.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
        if selectedVideoComment != nil{
            lblComment.isHidden = false
            lblComment.text = selectedVideoComment ?? ""
        }
    }
    


    //MARK: - UIButton Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
