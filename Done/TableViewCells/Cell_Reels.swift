//
//  Cell_Reels.swift
//  InstaReels
//
//  Created by Jay's Mac Mini on 25/09/21.
//

import UIKit
import AVFoundation
import AVKit

class Cell_Reels: UITableViewCell {

    
   @IBOutlet weak var marqueeLabel: UILabel!
   @IBOutlet weak var imgReels: UIImageView!

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerView1: PlayerView!
    
    @IBOutlet weak var userNameLbl : UILabel!
    
    var avPlayer: AVPlayer?
       var avPlayerLayer: AVPlayerLayer?
       var paused: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMoviePlayer()
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
          self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
          avPlayerLayer = AVPlayerLayer(player: avPlayer)
//          avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
          avPlayer?.volume = 2
          avPlayer?.actionAtItemEnd = .none

          //        You need to have different variations
          //        according to the device so as the avplayer fits well
//          if UIScreen.main.bounds.width == 375 {
//              let widthRequired = self.frame.size.width - 20
//              avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//          }else if UIScreen.main.bounds.width == 320 {
//              avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
//          }else{
//              let widthRequired = self.frame.size.width
//              avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//          }
          self.backgroundColor = .clear
          self.playerView1.layer.addSublayer(avPlayerLayer!)
          self.avPlayerLayer!.frame = self.playerView1.bounds

          // This notification is fired when the video ends, you can handle it in the method.
          NotificationCenter.default.addObserver(self,
                                                 selector: #selector(self.playerItemDidReachEnd(notification:)),
                                                 name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                 object: avPlayer?.currentItem)
      }

      func stopPlayback(){
          self.avPlayer?.pause()
      }

      func startPlayback(){
          self.avPlayer?.play()
      }

      // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
          let p: AVPlayerItem = notification.object as! AVPlayerItem
//          p.seek(to: CMTime.zero)
        p.seek(to: CMTime.zero, completionHandler: nil)
          
      }
    
}
