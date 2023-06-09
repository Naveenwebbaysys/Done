//
//  ReelsTableViewCell.swift
//  Done
//
//  Created by Mac on 31/05/23.
//

import UIKit
import AVFoundation
import AVKit

class ReelsTableViewCell: UITableViewCell {
    
    var observer: NSObjectProtocol?
    @IBOutlet weak var marqueeLabel: UILabel!
    @IBOutlet weak var userImgVW: UIImageView!
    @IBOutlet weak var reloadBtn : UIButton!
    @IBOutlet weak var playerView: UIView!
//    @IBOutlet weak var playerView1: PlayerView!
    
    @IBOutlet weak var userNameLbl : UILabel!
    @IBOutlet weak var dateLbl : UILabel!
    @IBOutlet weak var doneBtn : UIButton!
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMoviePlayer()
        reloadBtn.isHidden = true
        

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
            
        }
    }
    


    
    func setupMoviePlayer(){
        reloadBtn.isHidden = true
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
//        avPlayerLayer = AVPlayerLayer(player: avPlayer)
//        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        avPlayer?.volume = 2
        avPlayer?.actionAtItemEnd = .pause
    
        
        //        You need to have different variations
        //        according to the device so as the avplayer fits well
//                  if UIScreen.main.bounds.width == 375 {
//                      let widthRequired = self.frame.size.width - 20
//                      avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//                  }else if UIScreen.main.bounds.width == 320 {
//                      avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
//                  }else{
//                      let widthRequired = self.frame.size.width
//                      avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//                  }
//        self.backgroundColor = .clear
//        self.playerView.layer.addSublayer(avPlayerLayer!)
       
        

//        self.avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: self.playerView.frame.width, height: self.playerView.frame.height)
        
        // This notification is fired when the video ends, you can handle it in the method.
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
//                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
//                                               object: avPlayer?.currentItem)
        
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem, queue: .main) { [weak self] _ in
//                    self?.avPlayer?.seek(to: CMTime.zero)
//                    self?.avPlayer?.play()
//                }
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        
        // Observe the AVPlayerItemDidPlayToEndTime notification
                observer = NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: videoPlayerItem,
                    queue: nil) { [weak self] _ in
                    // Call the method to restart playback
                    self?.restartPlayback()
                }
        
        self.avPlayer?.play()
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero, completionHandler: nil)
//        startPlayback()
//        self.avPlayer?.seek(to: CMTime.zero)
        
//        self.avPlayer?.seek(to: CMTime.zero)
        self.avPlayer?.play()
//        reloadBtn.isHidden = false
//        reloadBtn.addTarget(self, action: #selector(replay), for: .touchUpInside)
        
    }
    
    @objc func replay()
    {
        startPlayback()
        reloadBtn.isHidden = true
        print("Reply clicked")
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        stopPlayback()
    }
    
    
    func restartPlayback() {
            // Seek to the beginning of the video
            avPlayer?.seek(to: CMTime.zero)
            
            // Start playback again
            avPlayer?.play()
        }

}

