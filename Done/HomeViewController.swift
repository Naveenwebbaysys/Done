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
    private var lastContentOffset: CGFloat = 0
    let activityIndicator = UIActivityIndicatorView(style: .large)
    var userID = ""
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
    
    var currentlyPlayingCell: ReelsTableViewCell?
    
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
        
        activityIndicator.center = view.center
        activityIndicator.color = .lightGray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        userID = UserDefaults.standard.value(forKey: UserDetails.userId) as! String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.reelsModelArray.removeAll()
        self.getReelsAPICall()
        
    }
    
    
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        if let cell = tblInstaReels.visibleCells.first as? ReelsTableViewCell {
    //            cell.avPlayer?.pause()
    //        }
    //
    //        print(":::: viewDidDisappear ::::")
    //    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                for cell in tblInstaReels.visibleCells {
                    print(":::: viewDidDisappear ::::")
                    (cell as! ReelsTableViewCell).avPlayer?.seek(to: CMTime.zero)
                    (cell as! ReelsTableViewCell).stopPlayback()
                    (cell as! ReelsTableViewCell ).avPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
                }
    }
    
    @IBAction func backBtnAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func getReelsAPICall()
    {
        APIModel.getRequest(strURL: BASEURL + GETREELSURL, postHeaders: headers as NSDictionary) { _result in
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
        //var visibleIP : IndexPath?
//                UIView.animate(withDuration: 12.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
//                    Reelcell.marqueeLabel.center = CGPoint.init(x: 35 - Reelcell.marqueeLabel.bounds.size.width / 2, y: Reelcell.marqueeLabel.center.y)
//                }, completion:  { _ in })

        Reelcell.userNameLbl.text = self.reelsModelArray[indexPath.row].assigneeName
        Reelcell.marqueeLabel.text = self.reelsModelArray[indexPath.row].notes

        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyy-MM-dd"

        let duedate = self.reelsModelArray[indexPath.row].commissionNoOfDays1!
        let yourDate = formatter.date(from: duedate)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "MMM d, yyyy"
        // again convert your date to string
        let myStringDate = formatter.string(from: yourDate!)

        print(myStringDate)
        let days = count(expDate: myStringDate)
        Reelcell.dateLbl.text = "Expires in " + "\(days)" + " days " + myStringDate
        let videoURL = URL(string: self.reelsModelArray[indexPath.row].videoURL!)
        Reelcell.videoPlayerItem = AVPlayerItem.init(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: Reelcell.avPlayer)
        playerLayer.frame = self.view.bounds
        Reelcell.playerView.layer.addSublayer(playerLayer)
        
        if firstTimeLoading == true
        {
            Reelcell.avPlayer?.play()
            //            player.play()
        }
        else{
            Reelcell.avPlayer?.pause()
            //            player.pause()
        }
        
        if userID == self.reelsModelArray[indexPath.row].createdBy
        {
            Reelcell.doneBtn.setTitle("View Status", for: .normal)
        }
        else
        {
            Reelcell.doneBtn.setTitle("Done?", for: .normal)
        }
        
        Reelcell.doneBtn.tag = indexPath.row
        Reelcell.doneBtn.addTarget(self, action: #selector(statusBtnTapped(_:)), for: .touchUpInside)
        Reelcell.avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        

        
        return Reelcell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tblInstaReels.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print("cell is displaying")
        print(indexPath.row)
        
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self!.activityIndicator.stopAnimating()
                    } else {
                        self!.activityIndicator.startAnimating()
                    }
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview!)
        if translation.y > 0 {
            print("scrolling down")
        } else {
            print("scrolling up")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let observer = observer {
                    NotificationCenter.default.removeObserver(observer)
                }
        if let indexPath2 = self.tblInstaReels.indexPathsForVisibleRows?.first {
                let previousIndexPath = IndexPath(row: indexPath2.row - 1, section: indexPath2.section)
                
                // Use the previousIndexPath as needed
//                print("Previous index path: \(previousIndexPath)")
//            print("Previous Row : \(previousIndexPath.row)")
//            print("Previous Section : \(previousIndexPath.section)")
//            print(scrollView.contentOffset.y)

            }
        
        
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

    }
    
    func stopPlayBack(cell : ReelsTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    
    func count (expDate : String) -> Int {
        print(expDate)
        let dateFormatter1 = DateFormatter()
        let dateFormatter2 = DateFormatter()
        dateFormatter1.dateFormat = "MMM d, yyyy"
        dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let today = dateFormatter2.string(from: Date())
        let formatedStartDate1 = dateFormatter2.date(from: today)
        let formatedStartDate2 = dateFormatter1.date(from: expDate)
        
        let diffInDays = Calendar.current.dateComponents([.day], from: formatedStartDate1!, to: formatedStartDate2!).day
        
        print(diffInDays!)
        return diffInDays! + 1
    }
    
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
//        p.seek(to: CMTime.zero)
//        p.seek(to: CMTime.zero, completionHandler: nil)
        p.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
//        startPlayback()
//        self.avPlayer?.seek(to: CMTime.zero)
        
//        self.avPlayer?.seek(to: CMTime.zero)


        for cell in tblInstaReels.visibleCells {
   
            (cell as! ReelsTableViewCell ).avPlayer?.play()
        }
        
        
    }
    
}





extension HomeViewController {
    
    @objc func statusBtnTapped(_ sender: UIButton?) {

        print("Tapped")
        let statusVC = storyboard?.instantiateViewController(identifier: "ViewStatusViewController") as! ViewStatusViewController
        statusVC.postID = self.reelsModelArray[sender!.tag].id!
        statusVC.notes = self.reelsModelArray[sender!.tag].notes!
        statusVC.dueDate = dateHelper(srt: self.reelsModelArray[sender!.tag].commissionNoOfDays1!) 
        self.navigationController?.pushViewController(statusVC, animated: true)
    }
}
