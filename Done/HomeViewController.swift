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
    var player = AVPlayer()
    var reelsModelArray = [Post]()
    var firstTimeLoading = true
    //MARK:- IBOutlets
    @IBOutlet weak var tblInstaReels: UITableView!
    
    //MARK:- Global Vaiables
    var arrImgs = ["p2.jpeg","p3.jpeg","p4.jpeg","p5.jpeg"]
    var arrVid = [ "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                  "https://medical-breakthrough.s3.us-west-1.amazonaws.com/DoneApp/_trimmedVideo_1685536948462.mp4",
                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                   "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_5MB.mp4"]
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblInstaReels.register(UINib(nibName: "ReelsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReelsTableViewCell")
        tblInstaReels.delegate = self
        tblInstaReels.dataSource = self
        visibleIP = IndexPath.init(row: 0, section: 0)
        tblInstaReels.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout
        tblInstaReels.tableFooterView = UIView()
        tblInstaReels.isPagingEnabled = true
        tblInstaReels.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.reelsModelArray.removeAll()
        self.getReelsAPICall()
        
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = tblInstaReels.visibleCells.first as? ReelsTableViewCell {
            cell.stopPlayback()        }
    }
    
    @IBAction func backBtnAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func getReelsAPICall()
    {
        serviceController.getRequest(strURL: BASEURL + GETREELSURL, postHeaders: headers as NSDictionary) { _result in
            let getReelsResponseModel = try? JSONDecoder().decode(GetReelsResponseModel.self, from: _result as! Data)
           

            print(getReelsResponseModel?.data as Any)
            if getReelsResponseModel?.data?.posts != nil
            {
                self.reelsModelArray = (getReelsResponseModel?.data?.posts)!
                
                self.tblInstaReels.reloadData()
                
                if let cell = self.tblInstaReels.visibleCells.first as? ReelsTableViewCell {
                    cell.reloadBtn.isHidden = true
                }
            }
            else
            {
                print("No Reels found")
            }
//
            
        } failure: { error in
            print(error)
        }

    }
    
}


//MARK:- UITableViewDelegate,UITableViewDataSource
extension HomeViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reelsModelArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Reelcell = self.tblInstaReels.dequeueReusableCell(withIdentifier: "ReelsTableViewCell") as! ReelsTableViewCell
//        UIView.animate(withDuration: 12.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
//            Reelcell.marqueeLabel.center = CGPoint.init(x: 35 - Reelcell.marqueeLabel.bounds.size.width / 2, y: Reelcell.marqueeLabel.center.y)
//        }, completion:  { _ in })
 
//        Reelcell.avPlayerLayer?.videoGravity = AVLayerVideoGravity.resize
//        Reelcell.videoPlayerItem = AVPlayerItem.init(url: URL(string:(self.arrVid[indexPath.row]))!)
        //var visibleIP : IndexPath?
        Reelcell.userNameLbl.text = self.reelsModelArray[indexPath.row].assigneeName
//        Reelcell.avPlayerLayer?.frame = self.view.bounds
//        Reelcell.playerView.layer.addSublayer((Reelcell.avPlayerLayer)!)
//        player = AVPlayer(url: URL(string:(self.arrVid[indexPath.row]))!)
        
        let videoURL = URL(string: self.reelsModelArray[indexPath.row].videoURL!)
        Reelcell.videoPlayerItem = AVPlayerItem.init(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: Reelcell.avPlayer)
        playerLayer.frame = self.view.bounds
        Reelcell.playerView.layer.addSublayer(playerLayer)
//        player.play()
        
        if firstTimeLoading == true
        {
            Reelcell.avPlayer?.play()
//            player.play()
        }
        else{
            Reelcell.avPlayer?.pause()
//            player.pause()
        }
        return Reelcell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tblInstaReels.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = (cell as? ReelsTableViewCell) else { return };
        let visibleCells = tableView.visibleCells
        let minIndex = visibleCells.startIndex
        if tableView.visibleCells.firstIndex(of: cell) == minIndex {
//            videoCell.playerView1.player?.play()

        }
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let indexPaths = self.tblInstaReels.indexPathsForVisibleRows
        var cells = [Any]()
        for ip in indexPaths!{
            if let videoCell = self.tblInstaReels.cellForRow(at: ip) as? ReelsTableViewCell{
                cells.append(videoCell)
            }
        }
        let cellCount = cells.count
        if cellCount == 0 {return}
        if cellCount == 1{
            if visibleIP != indexPaths?[0]{
                visibleIP = indexPaths?[0]
            }
            if let videoCell = cells.last! as? ReelsTableViewCell{
                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?.last)!)
            }
        }
        if cellCount >= 2 {
            firstTimeLoading = false
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
                        print ("visible = \(String(describing: indexPaths?[i]))")
                        if let videoCell = cells[i] as? ReelsTableViewCell{
                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                    }
                }
                else{
                    if aboutToBecomeInvisibleCell != indexPaths?[i].row{
                        aboutToBecomeInvisibleCell = (indexPaths?[i].row)!
                        if let videoCell = cells[i] as? ReelsTableViewCell{
                            self.stopPlayBack(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                        
                    }
                }
            }
        }
    }
    
    func playVideoOnTheCell(cell : ReelsTableViewCell, indexPath : IndexPath){
        cell.startPlayback()
//        player.play()
    }
    
    func stopPlayBack(cell : ReelsTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
//        player.pause()
    }
    
    
    
}
