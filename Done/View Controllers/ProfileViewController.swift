//
//  LogoutViewController.swift
//  Done
//
//  Created by Mac on 09/06/23.
//

import UIKit
import iOSDropDown
import AVFoundation
import KRProgressHUD

class ProfileViewController: UIViewController, indexProtocol {
    
    func indexID(i: Int) {
        menuIndex = i
    }
    
    var currentPage:Int = 1
    var isLastPage: Bool = false
    var idFromDone = false
    var selectedIndex = 0
    var menuIndex = 0
    var reelsModelArray = [Post]()
    var userID = ""
    var assignCommission = ""
    var stillworkingCommission = ""
    var doneCommission = ""
    var approvedCommission = ""
    var stType: String = "assigned_by_me"
    
    private let itemsPerRow: CGFloat = 3
    @IBOutlet weak var segmentVW : UIView!
    @IBOutlet weak var aulbumCW : UICollectionView!
    @IBOutlet weak var noTaskLbl : UILabel!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var deptLbl : UILabel!
    @IBOutlet weak var mailLbl : UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var commissionLbl : UILabel!
    @IBOutlet weak var assignBtn : UIButton!
    @IBOutlet weak var stillBtn : UIButton!
    @IBOutlet weak var donecBtn : UIButton!
    @IBOutlet weak var doneApprovedBtn : UIButton!
    @IBOutlet weak var indvw : UIView!
    
    @IBOutlet weak var stackVW : UIStackView!
    var assignLbl = UILabel()
    var stillLbl = UILabel()
    var doneLbl = UILabel()
    var approvedLbl = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aulbumCW.delegate = self
        self.aulbumCW.dataSource = self
        self.aulbumCW.register(UINib(nibName: "AulbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AulbumCollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        aulbumCW.setCollectionViewLayout(layout, animated: true)
        
        assignLbl.frame = CGRect(x: self.assignBtn.frame.minX, y: self.assignBtn.frame.maxY + 5, width: self.assignBtn.frame.width, height: 3)
        stillLbl.frame = CGRect(x: self.stillBtn.frame.minX, y: self.stillBtn.frame.maxY + 5, width: self.stillBtn.frame.width, height: 3)
        doneLbl.frame = CGRect(x: self.donecBtn.frame.minX, y: self.donecBtn.frame.maxY + 5, width: self.donecBtn.frame.width, height: 3)
        approvedLbl.frame = CGRect(x: self.doneApprovedBtn.frame.minX, y: self.doneApprovedBtn.frame.maxY + 5, width: self.doneApprovedBtn.frame.width, height: 3)
        
        stillLbl.isHidden = true
        doneLbl.isHidden = true
        approvedLbl.isHidden = true
        
//        assignLbl.backgroundColor = UIColor(named: "App_color")
//        stillLbl.backgroundColor = UIColor(named: "App_color")
//        doneLbl.backgroundColor = UIColor(named: "App_color")
//        approvedLbl.backgroundColor = UIColor(named: "App_color")
        
        self.stackVW.addSubview(assignLbl)
        self.stackVW.addSubview(stillLbl)
        self.stackVW.addSubview(doneLbl)
        self.stackVW.addSubview(approvedLbl)
        
    }
    
    override func viewDidLayoutSubviews() {
        showAssignIndicater()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reelsModelArray.removeAll()
        if let id = UserDefaults.standard.value(forKey: UserDetails.userId){
            userID = (id as? String)!
            getCommissionAPICall(withID: userID)
        }
        isLastPage = false
        currentPage = 1
        self.noTaskLbl.isHidden = true
        assignCommission = ""
        stillworkingCommission = ""
        doneCommission = ""
        selectedIndex = 0
//        if let i = UserDefaults.standard.value(forKey: "menuIndex")
//        {
//            menuIndex = i as! Int
//        }
        if let name = UserDefaults.standard.value(forKey: UserDetails.userName){
            self.nameLbl.text = name as? String
        }
        if let mail = UserDefaults.standard.value(forKey: UserDetails.userMailID){
            self.mailLbl.text = mail as? String
        }
        if let dept = UserDefaults.standard.value(forKey: UserDetails.deptName){
            self.deptLbl.text = dept as? String
        }
       
        
        //        self.noTaskLbl.isHidden = true
        self.reelsModelArray.removeAll()
        if menuIndex == 0{
            
            stType = "assigned_by_me"
            showAssignIndicater()
        }
        
        else if menuIndex == 1{
            stType = "still_working"
            showStillWorking()
        }
        
        else if menuIndex == 2{
            stType = "done_success"
            showDoneSuccess()
        }
        
        else if menuIndex == 3 {
            stType = "approved"
            showdoneApproved()
        }
//        self.getpostAPICall(withType: stType)
        self.getpostAPICall(withType: stType, page: currentPage)
        showAssignIndicater()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        UserDefaults.standard.set(menuIndex, forKey: "menuIndex")
    }
    
    func showAssignIndicater()
    {
//        self.assignLbl.isHidden = false
//        self.stillLbl.isHidden = true
//        self.doneLbl.isHidden = true
//        self.approvedLbl.isHidden = true
        self.assignBtn.titleLabel?.textColor = UIColor(named: "App_color")
        self.stillBtn.titleLabel?.textColor = .white
        self.donecBtn.titleLabel?.textColor = .white
        self.doneApprovedBtn.titleLabel?.textColor = .white
        isLastPage = false
    }
    
    func showStillWorking()
    {
//        self.assignLbl.isHidden = true
//        self.stillLbl.isHidden = false
//        self.doneLbl.isHidden = true
//        self.approvedLbl.isHidden = true
        self.assignBtn.titleLabel?.textColor = .white
        self.stillBtn.titleLabel?.textColor = UIColor(named: "App_color")
        self.donecBtn.titleLabel?.textColor = .white
        self.doneApprovedBtn.titleLabel?.textColor = .white
        isLastPage = false
    }
    
    func showDoneSuccess()
    {
//        self.assignLbl.isHidden = true
//        self.stillLbl.isHidden = true
//        self.doneLbl.isHidden = false
//        self.approvedLbl.isHidden = true
        self.assignBtn.titleLabel?.textColor = .white
        self.stillBtn.titleLabel?.textColor = .white
        self.donecBtn.titleLabel?.textColor = UIColor(named: "App_color")
        self.doneApprovedBtn.titleLabel?.textColor = .white
        isLastPage = false
    }
    
    func showdoneApproved()
    {
//        self.assignLbl.isHidden = true
//        self.stillLbl.isHidden = true
//        self.doneLbl.isHidden = true
//        self.approvedLbl.isHidden = false
        self.assignBtn.titleLabel?.textColor = .white
        self.stillBtn.titleLabel?.textColor = .white
        self.donecBtn.titleLabel?.textColor = .white
        self.doneApprovedBtn.titleLabel?.textColor = UIColor(named: "App_color")
        isLastPage = false
        
    }
    
    @IBAction func assignedBtnAct() {
        idFromDone = false
        menuIndex = 0
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        stType = "assigned_by_me"
        self.getpostAPICall(withType: stType , page: currentPage)
        self.noTaskLbl.isHidden = true
        showAssignIndicater()
        isLastPage = false
        
    }
    
    @IBAction func stillBtnAct() {
        idFromDone = false
        menuIndex = 1
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        stType = "still_working"
        self.getpostAPICall(withType: stType, page: currentPage)
   
        self.noTaskLbl.isHidden = true
        showStillWorking()
        
    }
    @IBAction func doneBtnAct() {
        idFromDone = true
        menuIndex = 2
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        stType = "done_success"
        self.getpostAPICall(withType: stType, page: currentPage)
        self.noTaskLbl.isHidden = true
        showDoneSuccess()
       
    }
    
    @IBAction func doneApprovedBtnAct() {
        idFromDone = true
        menuIndex = 3
        self.reelsModelArray.removeAll()
        isLastPage = false
        currentPage = 1
        stType = "approved"
        self.getpostAPICall(withType: stType, page: currentPage)
        self.noTaskLbl.isHidden = true
        showdoneApproved()
    }
    
    func getCommissionAPICall(withID : String){
        
        APIModel.getRequest(strURL: BASEURL + COMMISSIONAPI + withID , postHeaders: headers as NSDictionary) { jsonData in
            let commissionResponse = try? JSONDecoder().decode(CommissionResponseModel.self, from: jsonData as! Data)
            if commissionResponse?.data != nil
            {
                self.commissionLbl.text = "$ " + (commissionResponse?.data?.approvedcommission?.commission ?? "")
                
                self.assignCommission = (commissionResponse?.data?.assignedByCommission?.commission ?? "") + "(" + (commissionResponse?.data?.assignedByCommission?.commissionCount ?? "") + ")"
                self.stillworkingCommission = (commissionResponse?.data?.stillWorkingCommission?.commission ?? "") + "(" + (commissionResponse?.data?.stillWorkingCommission?.commissionCount ?? "") + ")"
                self.doneCommission =  (commissionResponse?.data?.doneCommission?.commission ?? "") + "(" + (commissionResponse?.data?.doneCommission?.commissionCount ?? "") + ")"
                
                self.approvedCommission = (commissionResponse?.data?.approvedcommission?.commission ?? "") + "(" + (commissionResponse?.data?.approvedcommission?.commissionCount ?? "") + ")"
                
                print(self.assignCommission)
                print(self.stillworkingCommission)
                print(self.stillworkingCommission)
                
                let part1 = NSAttributedString(string: "Assigend by me  $"  + self.assignCommission)
                self.assignBtn.setAttributedTitle(part1, for: .normal)
                self.assignBtn.titleLabel?.textAlignment = .center
                
                let part2 = NSAttributedString(string: "Still working  "  + "\n" +  "$" + self.stillworkingCommission)
                self.stillBtn.setAttributedTitle(part2, for: .normal)
                self.stillBtn.titleLabel?.textAlignment = .center
                
                let part3 = NSAttributedString(string: "Done Need to Check "  + "$" + self.doneCommission)
                self.donecBtn.setAttributedTitle(part3, for: .normal)
                self.donecBtn.titleLabel?.textAlignment = .center
                
                let part4 = NSAttributedString(string: "Done Approved " + "\n" + "$" + self.approvedCommission)
                self.doneApprovedBtn.setAttributedTitle(part4, for: .normal)
                self.doneApprovedBtn.titleLabel?.textAlignment = .center
            }
            
        } failure: { error in
            print(error)
        }
    }
    
    func getpostAPICall(withType : String, page:Int){
//        self.reelsModelArray.removeAll()
        let url = BASEURL + GETREELSURL + withType + "&sort_due_date=desc" + "&page_no=\(page)"
        print(url)
//        if page == 1{
//            KRProgressHUD.show()
//        }
        
        APIModel.getRequest(strURL: url , postHeaders: headers as NSDictionary) { _result in
//            if page == 1{
//                KRProgressHUD.dismiss()
//            }
            
            let getReelsResponseModel = try? JSONDecoder().decode(GetReelsResponseModel.self, from: _result as! Data)
//            print(getReelsResponseModel?.data as Any)
            if getReelsResponseModel?.data != nil
            {
                print(getReelsResponseModel?.data?.posts?.count)
                for data in (getReelsResponseModel?.data?.posts ?? [Post]()){
                    self.reelsModelArray.append(data)
                }
                self.isLastPage = (getReelsResponseModel?.data?.posts ?? [Post]()).count == 10 ? false : true
                self.aulbumCW.reloadData()

                if self.reelsModelArray.count == 0
                {
                    print("No Reels found")
                    self.noTaskLbl.isHidden = false
                }
            }
            else
            {
                print("No Reels found")
                self.noTaskLbl.isHidden = false
            }
           
            //
        } failure: { error in
            if page == 1{
                KRProgressHUD.dismiss()
            }
            print(error)
        }
    }
    
}


extension ProfileViewController {
    
    @IBAction func logoutBtnAction()
    {
        self.openAlert(title: "Alert", message: "Are you sure want to Logout?",alertStyle: .alert,
                       actionTitles: ["Cancel", "Ok"],actionStyles: [.destructive, .default],
                       actions: [
                        {_ in print("cancel click")},{_ in print("Okay click")
                            self.logoutAct()
                        }])
        
    }
    func logoutAct()
    {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}


extension ProfileViewController : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reelsModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "AulbumCollectionViewCell", for: indexPath) as! AulbumCollectionViewCell
        let videoUrl = URL(string: self.reelsModelArray[indexPath.row].videoURL ?? "")
        item.thumbNailImageVW.image = getVideoThumbnail(url: videoUrl!)
        let amount = self.reelsModelArray[indexPath.row].commissionAmount ?? "0"
        
        let tagpeople = self.reelsModelArray[indexPath.row].tagPeoples?.count ?? 0
        item.amountLbl.text = "\(Int(amount)! * tagpeople)"
        
        if userID == self.reelsModelArray[indexPath.row].createdBy
        {
            item.commentCountLbl.text = self.reelsModelArray[indexPath.row].totalcommentscount
        }
        else
        {
            if self.reelsModelArray[indexPath.row].tagPeoples?[0].comments?.isEmpty == true {
                item.commentCountLbl.text = "0"
            }
            else
            {
                item.commentCountLbl.text = self.reelsModelArray[indexPath.row].tagPeoples?[0].comments?[0].comment
            }
        }
        
        item.assignCountLbl.text = "\(self.reelsModelArray[indexPath.row].tagPeoples?.count ?? 0)"
        
        if indexPath.row == self.reelsModelArray.count - 3 {
            if !isLastPage{
                print("Coniddtion done.",indexPath.row)
                currentPage += 1
                self.getpostAPICall(withType: stType, page: currentPage)
            }
        }
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        /// 2
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let lay = collectionViewLayout as! UICollectionViewFlowLayout
        let widthPerItem = collectionView.frame.width / 3 - lay.minimumInteritemSpacing
        return CGSize(width: widthPerItem - 1, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let viewVidepVC = storyboard?.instantiateViewController(withIdentifier: "PlayVideoViewController") as! PlayVideoViewController
        viewVidepVC.reelModelArray.removeAll()
        viewVidepVC.reelModelArray.append(self.reelsModelArray[indexPath.row])
        viewVidepVC.idFromDone = idFromDone
        viewVidepVC.selectedIndex = menuIndex
        viewVidepVC.delegate? = self
        self.navigationController?.pushViewController(viewVidepVC, animated: true)
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        let visibleHeight = scrollView.frame.height
//
//        if offsetY > contentHeight - visibleHeight {
//            print("Showing next page")
//            currentPage += 1
//            self.getpostAPICall(withType: stType, page: currentPage)
//        }
//
//    }
    
}


extension ProfileViewController {
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async {
            let imageCache = NSCache<AnyObject, AnyObject>()
            if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) {
                DispatchQueue.main.async {
                    completion((imageFromCache as! UIImage))
                }
                return
            }
            
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(value: 0, timescale: 1) // Get the thumbnail from the beginning of the video
            
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                var thumbnailImage = UIImage(cgImage: cgThumbImage)
                
                // Resize the thumbnail image if needed
                let thumbnailSize = CGSize(width: 50, height: 50) // Adjust the size as per your requirements
                if thumbnailImage.size != thumbnailSize {
                    UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0.0)
                    thumbnailImage.draw(in: CGRect(origin: .zero, size: thumbnailSize))
                    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext() ?? thumbnailImage
                    UIGraphicsEndImageContext()
                }
                
                DispatchQueue.main.async {
                    completion(thumbnailImage)
                }
                
                imageCache.setObject(thumbnailImage, forKey: (url.absoluteString as AnyObject))
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    
}

