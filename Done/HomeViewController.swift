//
//  ViewController.swift
//  InstaReels
//
//  Created by Jay's Mac Mini on 25/09/21.
//

import UIKit
import AVFoundation
import AVKit
class HomeViewController: UIViewController {
    
    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var videoURLs = Array<URL>()
    var firstLoad = true
    var visibleIP : IndexPath?
    
    
    //MARK:- IBOutlets
    @IBOutlet weak var tblInstaReels: UITableView!
    
    //MARK:- Global Vaiables
    var arrImgs = ["p2.jpeg","p3.jpeg","p4.jpeg","p5.jpeg"]
    var arrVid = ["https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_5MB.mp4", "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"]
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblInstaReels.register(UINib(nibName: "Cell_Reels", bundle: nil), forCellReuseIdentifier: "Cell_Reels")
        tblInstaReels.delegate = self
        tblInstaReels.dataSource = self
        visibleIP = IndexPath.init(row: 0, section: 0)
    }
    
    @IBAction func backBtnAction(){
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK:- UITableViewDelegate,UITableViewDataSource
extension HomeViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrVid.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Reelcell = self.tblInstaReels.dequeueReusableCell(withIdentifier: "Cell_Reels") as! Cell_Reels
        UIView.animate(withDuration: 12.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
            Reelcell.marqueeLabel.center = CGPoint.init(x: 35 - Reelcell.marqueeLabel.bounds.size.width / 2, y: Reelcell.marqueeLabel.center.y)
        }, completion:  { _ in })
        //        Reelcell.imgReels.image = UIImage.init(named: arrImgs[indexPath.row])
        
        //        let videoURL = URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_5MB.mp4")
        //        let avPlayer = AVPlayer(url: URL(string:(arrVid[indexPath.row]))!)
        //        Reelcell.playerView1?.playerLayer.player = avPlayer
        //        avPlayer.play()
        Reelcell.videoPlayerItem = AVPlayerItem.init(url: URL(string:(arrVid[indexPath.row]))!)//var visibleIP : IndexPath?
        
        return Reelcell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tblInstaReels.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = (cell as? Cell_Reels) else { return };
        let visibleCells = tableView.visibleCells
        let minIndex = visibleCells.startIndex
        if tableView.visibleCells.firstIndex(of: cell) == minIndex {
            videoCell.playerView1.player?.play()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print("end = \(indexPath)")
        if let videoCell = cell as? Cell_Reels {
//            videoCell.stopPlayback()
            self.stopPlayBack(cell: videoCell, indexPath: (indexPath))
            
            videoCell.avPlayer?.pause()
        }
        
        //            guard let videoCell = cell as? Cell_Reels else { return };
        //
        //            videoCell.playerView1?.playerLayer.player?.pause()
        //            videoCell.playerView1.player = nil
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = self.tblInstaReels.indexPathsForVisibleRows
        var cells = [Any]()
        for ip in indexPaths!{
            if let videoCell = self.tblInstaReels.cellForRow(at: ip) as? Cell_Reels{
                cells.append(videoCell)
            }
        }
        let cellCount = cells.count
        if cellCount == 0 {return}
        if cellCount == 1{
            if visibleIP != indexPaths?[0]{
                visibleIP = indexPaths?[0]
            }
            if let videoCell = cells.last! as? Cell_Reels{
                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?.last)!)
            }
        }
        if cellCount >= 2 {
            for i in 0..<cellCount{
                let cellRect = self.tblInstaReels.rectForRow(at: (indexPaths?[i])!)
                let intersect = cellRect.intersection(self.tblInstaReels.bounds)
                //                curerntHeight is the height of the cell that
                //                is visible
                let currentHeight = intersect.height
                print("\n \(currentHeight)")
                let cellHeight = (cells[i] as AnyObject).frame.size.height
                //                0.95 here denotes how much you want the cell to display
                //                for it to mark itself as visible,
                //                .95 denotes 95 percent,
                //                you can change the values accordingly
                if currentHeight > (cellHeight * 0.95){
                    if visibleIP != indexPaths?[i]{
                        visibleIP = indexPaths?[i]
                        print ("visible = \(indexPaths?[i])")
                        if let videoCell = cells[i] as? Cell_Reels{
                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                    }
                }
                else{
                    if aboutToBecomeInvisibleCell != indexPaths?[i].row{
                        aboutToBecomeInvisibleCell = (indexPaths?[i].row)!
                        if let videoCell = cells[i] as? Cell_Reels{
                            self.stopPlayBack(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                        
                    }
                }
            }
        }
    }
    
    func playVideoOnTheCell(cell : Cell_Reels, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : Cell_Reels, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    
    
}
