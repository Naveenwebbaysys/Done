//
//  ViewController.swift
//  InstaReels
//
//  Created by Jay's Mac Mini on 25/09/21.
//

import UIKit
import AVFoundation
import AVKit
import HMSegmentedControl
import KRProgressHUD

class HomeViewController: UIViewController,delegateFiltersVC,taskProofviewDelegate {
    
    private var lastContentOffset: CGFloat = 0
    var groupIDString = ""
    var menuIndex = 0
    var isSuccess = false
    var assignCommission = ""
    var idFromDone = false
    var stillworkingCommission = ""
    var doneCommission = ""
    var repeatStarted = false
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
    var currentlyPlayingCell: ReelsTableViewCell?
    var currentPage:Int = 1
    var isLastPage: Bool = false
    var stType: String = "assigned_by_me"
    
    var arrSelectedDueDate: [String] = [String]()
    var arrSelectedAssignee: [List] = [List]()
    
    @IBOutlet weak var indvw : UIView!
    @IBOutlet weak var segmentVW : UIView!
    @IBOutlet weak var noTaskLbl : UILabel!
    @IBOutlet weak var assignBtn : UIButton!
    @IBOutlet weak var stillBtn : UIButton!
    @IBOutlet weak var donecBtn : UIButton!
    @IBOutlet weak var iNeedDoneBtn : UIButton!
    @IBOutlet weak var tblInstaReels: UITableView!
    
    
    //MARK: - View Life Cycle
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
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        if #available(iOS 11.0, *) {
            tblInstaReels.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.noTaskLbl.isHidden = true
        self.firstTimeLoading = true
        self.isSuccess = false
        self.navigationController?.isNavigationBarHidden = true
        userID = UserDefaults.standard.value(forKey: UserDetails.userId) as! String
        
        
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        if menuIndex == 0{
            stType = "assigned_by_me"
            self.assignBtn.titleLabel?.textColor = UIColor(named: "App_color")
            self.stillBtn.titleLabel?.textColor = .white
            self.donecBtn.titleLabel?.textColor = .white
            self.iNeedDoneBtn.titleLabel?.textColor = .white
        }
        else if menuIndex == 1{
            stType = "still_working"
            self.stillBtn.titleLabel?.textColor = UIColor(named: "App_color")
        }
        else if menuIndex == 2{
            stType = "done_success"
            self.donecBtn.titleLabel?.textColor = UIColor(named: "App_color")
        }
        else if menuIndex == 3{
            stType = "approved"
            self.iNeedDoneBtn.titleLabel?.textColor = UIColor(named: "App_color")
        }
        
        self.activityIndicator.stopAnimating()
        
        if let id = UserDefaults.standard.value(forKey: UserDetails.userId)
        {
            getGroupsAPICall(withLoginId: id as! String)
        }
    }
    
    override func viewDidLayoutSubviews() {
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in tblInstaReels.visibleCells {
            print(":::: viewDidDisappear ::::")
            (cell as! ReelsTableViewCell).avPlayer?.seek(to: CMTime.zero)
            (cell as! ReelsTableViewCell).stopPlayback()
           // (cell as! ReelsTableViewCell ).avPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
        }
        if repeatStarted == true {
            NotificationCenter.default.removeObserver(self)
        }
        UserDefaults.standard.set(menuIndex, forKey: "menuIndex")
    }
    
    @IBAction func backBtnAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func assignedBtnAct() {
        self.assignBtn.titleLabel?.textColor = UIColor(named: "App_color")
        self.stillBtn.titleLabel?.textColor = .white
        self.donecBtn.titleLabel?.textColor = .white
        self.iNeedDoneBtn.titleLabel?.textColor = .white
        getCommissionAPICall(withID: userID)
        observers()
        menuIndex = 0
        idFromDone = false
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        stType = "assigned_by_me"
        self.getpostAPICall(withType: stType , page: currentPage)
    }
    
    @IBAction func stillBtnAct() {
        self.assignBtn.titleLabel?.textColor = .white
        self.stillBtn.titleLabel?.textColor = UIColor(named: "App_color")
        self.donecBtn.titleLabel?.textColor = .white
        self.iNeedDoneBtn.titleLabel?.textColor = .white
        getCommissionAPICall(withID: userID)
        observers()
        menuIndex = 1
        idFromDone = false
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        stType = "still_working"
        self.getpostAPICall(withType: stType, page: currentPage)
    }
    
    @IBAction func doneBtnAct() {
        self.assignBtn.titleLabel?.textColor = .white
        self.stillBtn.titleLabel?.textColor = .white
        self.donecBtn.titleLabel?.textColor = UIColor(named: "App_color")
        self.iNeedDoneBtn.titleLabel?.textColor = .white
        getCommissionAPICall(withID: userID)
        observers()
        menuIndex = 2
        idFromDone = true
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        stType = "done_success"
        self.getpostAPICall(withType: stType, page: currentPage)
        
    }
    
    @IBAction func iNeedDoneBtnAct() {
        self.assignBtn.titleLabel?.textColor = .white
        self.stillBtn.titleLabel?.textColor = .white
        self.donecBtn.titleLabel?.textColor = .white
        self.iNeedDoneBtn.titleLabel?.textColor = UIColor(named: "App_color")
        getCommissionAPICall(withID: userID)
        observers()
        menuIndex = 3
        idFromDone = true
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        stType = "approved"
        self.getpostAPICall(withType: stType, page: currentPage)
        
    }
    
    @IBAction func filterBtnAct() {
        
        let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "FiltersViewController") as! FiltersViewController
        filterVC.delegate = self
        filterVC.arrSelectedDueDate = self.arrSelectedDueDate
        filterVC.arrSelectedAssignee = self.arrSelectedAssignee
        self.navigationController?.pushViewController(filterVC, animated: true)
    }
    
    func getCommissionAPICall(withID : String){
        APIModel.getRequest(strURL: BASEURL + COMMISSIONAPI + withID + "&group_id=" + self.groupIDString, postHeaders: headers as NSDictionary) { jsonData in
            var approvedCom = ""
            let commissionResponse = try? JSONDecoder().decode(CommissionResponseModel.self, from: jsonData as! Data)
            if commissionResponse?.data != nil
            {
                self.assignCommission = (commissionResponse?.data?.assignedByCommission?.commission ?? "") + "(" + (commissionResponse?.data?.assignedByCommission?.commissionCount ?? "") + ")"
                self.stillworkingCommission = (commissionResponse?.data?.stillWorkingCommission?.commission ?? "") + "(" + (commissionResponse?.data?.stillWorkingCommission?.commissionCount ?? "") + ")"
                self.doneCommission =  (commissionResponse?.data?.doneCommission?.commission ?? "") + "(" + (commissionResponse?.data?.doneCommission?.commissionCount ?? "") + ")"
                approvedCom = (commissionResponse?.data?.approvedcommission?.commission ?? "") + "(" + (commissionResponse?.data?.approvedcommission?.commissionCount ?? "") + ")"
                
            }
            print(self.assignCommission)
            print(self.stillworkingCommission)
            print(self.stillworkingCommission)
            print(approvedCom)
            
            let part1 = NSAttributedString(string: "Available "  + "\n" + "$" + self.assignCommission)
            self.assignBtn.setAttributedTitle(part1, for: .normal)
            self.assignBtn.titleLabel?.textAlignment = .center
            //            self.assignBtn.titleLabel?.textColor = UIColor(named: "App_color")
            
            let part2 = NSAttributedString(string: "Working " + "\n" + "$" + self.stillworkingCommission)
            self.stillBtn.setAttributedTitle(part2, for: .normal)
            self.stillBtn.titleLabel?.textAlignment = .center
            //            self.stillBtn.titleLabel?.textColor = .white
            
            let part3 = NSAttributedString(string: "Need Approval " + "\n" + "$" + self.doneCommission)
            self.donecBtn.setAttributedTitle(part3, for: .normal)
            self.donecBtn.titleLabel?.textAlignment = .center
            
            let part4 = NSAttributedString(string: "Need Done " + "\n" + "$" + approvedCom)
            self.iNeedDoneBtn.setAttributedTitle(part4, for: .normal)
            self.iNeedDoneBtn.titleLabel?.textAlignment = .center
            //            self.donecBtn.titleLabel?.textColor = .white
            
        } failure: { error in
            print(error)
        }
    }
    
    func observers(){
        self.noTaskLbl.isHidden = true
        self.activityIndicator.stopAnimating()
        for cell in tblInstaReels.visibleCells {
            print(":::: Segmented Control Changed ::::")
            (cell as! ReelsTableViewCell).avPlayer?.seek(to: CMTime.zero)
            (cell as! ReelsTableViewCell).stopPlayback()
            (cell as! ReelsTableViewCell).avPlayer?.pause()
            (cell as! ReelsTableViewCell ).avPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
        }
        if repeatStarted == true {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func getGroupsAPICall(withLoginId : String)
    {
        APIModel.getRequest(strURL: BASEURL + GETGROUPSAPI + withLoginId, postHeaders: headers as NSDictionary) { [self] jsonResult in
            let groupsResponse = try? JSONDecoder().decode(GetGroupsResponseModel.self, from: jsonResult as! Data)
            if groupsResponse?.data?.groups != nil
            {
                var groupsArray = (groupsResponse?.data?.groups)!
                var groups = [String]()
                
                for (i,_) in groupsArray.enumerated(){
                    
                    groups.append(groupsArray[i].id!)
                }
                self.groupIDString = groups.joined(separator: ",")
                print(self.groupIDString)
            }
            else
            {
                print("No Groups found")
            }
            self.getpostAPICall(withType: self.stType, page: self.currentPage)
            if let id = UserDefaults.standard.value(forKey: UserDetails.userId){
                self.userID = (id as? String)!
                getCommissionAPICall(withID: userID)
            }
        } failure: { error in
            print(error)
        }
    }
    
    func getpostAPICall(withType : String,page:Int){
        var stSortDue: String = "desc"
        if arrSelectedDueDate.isEmpty{
            stSortDue = "desc"
        }else{
            if arrSelectedDueDate[0] == "Latest Task"{
                stSortDue = "desc"
            }else{
                stSortDue = "asc"
            }
        }
        let url = BASEURL + GETREELSURL + withType + "&sort_due_date=\(stSortDue)" + "&page_no=\(page)" + "&group_id=" + self.groupIDString
        print(url)
        if page == 1{
            KRProgressHUD.show()
        }
        APIModel.backGroundGetRequest(strURL: url, postHeaders: headers as NSDictionary) { _result in
            if page == 1{
                KRProgressHUD.dismiss()
            }
            let getReelsResponseModel = try? JSONDecoder().decode(GetReelsResponseModel.self, from: _result as! Data)
            self.noTaskLbl.isHidden = true
            //            print(getReelsResponseModel?.data as Any)
            if getReelsResponseModel?.data?.posts?.isEmpty == false
            {
                //                self.reelsModelArray = (getReelsResponseModel?.data?.posts)!
                for data in (getReelsResponseModel?.data?.posts ?? [Post]()){
                    self.reelsModelArray.append(data)
                }
                self.isLastPage = (getReelsResponseModel?.data?.posts ?? [Post]()).count == 10 ? false : true
                if let cell = self.tblInstaReels.visibleCells.first as? ReelsTableViewCell {
                    cell.reloadBtn.isHidden = true
                }
            }
            else
            {
                print("No Reels found")
                self.reelsModelArray = []
                self.noTaskLbl.isHidden = false
            }
            self.tblInstaReels.reloadData()
        } failure: { error in
            if page == 1{
                KRProgressHUD.dismiss()
            }
            print(error)
        }
    }
    
    //MARK: -  delegate FiltersVC
    func setFilterValue(arrSelectedDueDate: [String], arrSelectedAssignee: [List]) {
        self.arrSelectedDueDate = arrSelectedDueDate
        self.arrSelectedAssignee = arrSelectedAssignee
        self.currentPage += 1
        self.getpostAPICall(withType: stType, page: currentPage)
    }
    
    func taskProofDone(index: Int) {
        self.isSuccess = true
        //            self.reelsModelArray[index].
        let indexPathRow:Int = index
        let indexPosition = IndexPath(row: indexPathRow, section: 0)
        self.tblInstaReels.reloadRows(at: [indexPosition], with: .none)
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
        formatter.dateFormat = "yyy-MM-dd"
        let duedate = self.reelsModelArray[indexPath.row].commissionNoOfDays1!
        let yourDate = formatter.date(from: duedate)
        formatter.dateFormat = "MMM d, yyyy"
        var days = 0
        if yourDate != nil{
            let myStringDate = formatter.string(from: yourDate!)
            days = count(expDate: myStringDate)
            Reelcell.dateLbl.text = "Expires in " + "\(days)" + " days - " + myStringDate
        }
        
        let videoURL = URL(string: self.reelsModelArray[indexPath.row].videoURL!)
        if videoURL !=  nil{
            Reelcell.videoPlayerItem = AVPlayerItem.init(url: videoURL!)
            let playerLayer = AVPlayerLayer(player: Reelcell.avPlayer)
            playerLayer.frame = self.view.bounds
            playerLayer.videoGravity = AVLayerVideoGravity.resize
            Reelcell.playerView.layer.addSublayer(playerLayer)
            if firstTimeLoading == true
            {
                Reelcell.avPlayer?.play()
            }
            else{
                Reelcell.avPlayer?.pause()
            }
        }
        if idFromDone == true
        {
            Reelcell.dontBtnWidth.constant = 0
        }
        else
        {
            Reelcell.dontBtnWidth.constant = 100
        }
        if userID == self.reelsModelArray[indexPath.row].createdBy
        {
            Reelcell.editBtn.isHidden = false
            Reelcell.doneBtn.setTitle("View Status", for: .normal)
            Reelcell.countLbl.text = self.reelsModelArray[indexPath.row].totalcommentscount
            Reelcell.editHeight.constant = 28
            Reelcell.dontBtnWidth.constant = 0
        }
        else
        {
            Reelcell.editHeight.constant = 0
            Reelcell.dontBtnWidth.constant = 100
            Reelcell.editBtn.isHidden = true
            if  isSuccess == true
            {
                Reelcell.doneBtn.setTitle("Success", for: .normal)
            }
            else
            {
                Reelcell.doneBtn.setTitle("Done?", for: .normal)
            }
            
            let arrTagPeople = (self.reelsModelArray[indexPath.row].tagPeoples) ?? [TagPeople]()
                       if !arrTagPeople.isEmpty{
                           if arrTagPeople[0].comments?.isEmpty == true {
                               Reelcell.countLbl.text = "0"
                           }
                           else
                           {
                               Reelcell.countLbl.text = arrTagPeople[0].comments?[0].comment
                           }
                       }else{
                           Reelcell.countLbl.text = "0"
                       }
        }
        Reelcell.commissionBtn.tag = indexPath.row
        let amount = "$" + (self.reelsModelArray[indexPath.row].commissionAmount ?? "0") + " - DUE IN " + "\(days)" + " DAYS "
        Reelcell.commissionBtn.setTitle(amount, for: .normal)
        Reelcell.doneBtn.tag = indexPath.row
        Reelcell.doneBtn.addTarget(self, action: #selector(statusBtnTapped(_:)), for: .touchUpInside)
        Reelcell.commentsBtn.tag = indexPath.row
        Reelcell.editBtn.tag = indexPath.row
        Reelcell.editBtn.addTarget(self, action: #selector(editBtnTapped(_:)), for: .touchUpInside)
        Reelcell.commentsBtn.addTarget(self, action: #selector(commentsBtnTapped(_:)), for: .touchUpInside)
        Reelcell.avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        var arrTag = [String]()
        if self.reelsModelArray[indexPath.row].categoryname != nil{
            arrTag.append("#\(self.reelsModelArray[indexPath.row].categoryname ?? "")")
        }
        if self.reelsModelArray[indexPath.row].subcategoryname != nil{
            arrTag.append("#\(self.reelsModelArray[indexPath.row].subcategoryname ?? "")")
        }
        Reelcell.lblCategoryNameAndSubCategory.text = arrTag.joined(separator: " , ")
        NotificationCenter.default.addObserver(self, selector: #selector(restartPlayback), name: .AVPlayerItemDidPlayToEndTime, object: Reelcell.avPlayer?.currentItem)
        
        if indexPath.row == self.reelsModelArray.count - 4 {
            if !isLastPage{
                print("Coniddtion done.",indexPath.row)
                currentPage += 1
                self.getpostAPICall(withType: stType, page: currentPage)
            }
        }
        return Reelcell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tblInstaReels.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print("cell is displaying")
        print(indexPath.row)
        
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? ReelsTableViewCell {
            // Stop the video when the cell is no longer visible
            videoCell.avPlayer?.pause()
        }
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
                        //                        print ("visible = \(String(describing: indexPaths?[i]))")
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
        //        print(diffInDays!)
        return diffInDays! + 1
    }
    
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        for cell in tblInstaReels.visibleCells {
            (cell as! ReelsTableViewCell ).avPlayer?.play()
        }
    }
    
    @objc func restartPlayback() {
        // Seek to the beginning of the video
        print("Player started again")
        repeatStarted = true
        for cell in tblInstaReels.visibleCells {
            self.activityIndicator.stopAnimating()
            (cell as! ReelsTableViewCell ).avPlayer?.seek(to: CMTime.zero)
            (cell as! ReelsTableViewCell ).avPlayer?.play()
        }
    }
}


extension HomeViewController {
    @objc func statusBtnTapped(_ sender: UIButton?) {
        print("Tapped")
        
        
        if sender?.titleLabel?.text ==  "Done?"
        {
            //            updatesAPICall(withTask: "done_success", index: sender!.tag)
            let taskProofView = TaskProofView.init(info: "done_success", postID:  Int(self.reelsModelArray[sender!.tag].id ?? "0")!, employeeID: Int(userID)!, index: sender!.tag)
            taskProofView.delegate = self
        }
        else
        {
//                    let statusVC = storyboard?.instantiateViewController(identifier: "ViewStatusViewController") as! ViewStatusViewController
//                    statusVC.postID = self.reelsModelArray[sender!.tag].id ?? ""
//                    statusVC.notes = self.reelsModelArray[sender!.tag].notes ?? ""
//                    statusVC.dueDate = dateHelper(srt: self.reelsModelArray[sender!.tag].commissionNoOfDays1!)
//                    statusVC.index = sender!.tag
//                    statusVC.reelsModelArray = self.reelsModelArray
//                    statusVC.isFromEdit = true
//                    self.navigationController?.pushViewController(statusVC, animated: true)

        }
    }
    
    @objc func commentsBtnTapped(_ sender: UIButton?) {
        print("Comment Tapped")
        let commentsVC = storyboard?.instantiateViewController(identifier: "CommentsViewController") as! CommentsViewController
        print(self.reelsModelArray[sender!.tag].tagPeoples?[0].orderAssigneeEmployeeID)
        commentsVC.assignEmpID = (self.reelsModelArray[sender!.tag].tagPeoples?[0].orderAssigneeEmployeeID)!
        commentsVC.desc = self.reelsModelArray[sender!.tag].notes!
        commentsVC.empID = self.reelsModelArray[sender!.tag].id!
        commentsVC.employeeID = (self.reelsModelArray[sender!.tag].tagPeoples?[0].employeeID) ?? ""
        commentsVC.postid = self.reelsModelArray[sender!.tag].id!
        commentsVC.createdBy = self.reelsModelArray[sender!.tag].createdBy!
        
//            commentsVC.postPeopleSelected = self.reelsModelArray[sender!.tag].tagPeoples?[0]
        //        statusVC.dueDate = dateHelper(srt: self.reelsModelArray[sender!.tag].commissionNoOfDays1!)
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    @objc func editBtnTapped(_ sender: UIButton?) {
        print("Edit Tapped")
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        postVC.reelsModelArray = self.reelsModelArray
        postVC.index = sender!.tag
        postVC.isFromEdit = true
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
}
