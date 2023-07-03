//
//  LogoutViewController.swift
//  Done
//
//  Created by Mac on 09/06/23.
//

import UIKit
import iOSDropDown
import AVFoundation


class ProfileViewController: UIViewController {
    var selectedIndex = 0
    var reelsModelArray = [Post]()
    var userID = ""
    var assignCommission = ""
    var stillworkingCommission = ""
    var doneCommission = ""
    var approvedCommission = ""
    
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
        
        assignLbl.backgroundColor = UIColor(named: "App_color")
        stillLbl.backgroundColor = UIColor(named: "App_color")
        doneLbl.backgroundColor = UIColor(named: "App_color")
        approvedLbl.backgroundColor = UIColor(named: "App_color")
        
        self.stackVW.addSubview(assignLbl)
        self.stackVW.addSubview(stillLbl)
        self.stackVW.addSubview(doneLbl)
        self.stackVW.addSubview(approvedLbl)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.noTaskLbl.isHidden = true
        assignCommission = ""
        stillworkingCommission = ""
        doneCommission = ""
        selectedIndex = 0
        
        if let name = UserDefaults.standard.value(forKey: UserDetails.userName){
            self.nameLbl.text = name as? String
        }
        if let mail = UserDefaults.standard.value(forKey: UserDetails.userMailID){
            self.mailLbl.text = mail as? String
        }
        if let dept = UserDefaults.standard.value(forKey: UserDetails.deptName){
            self.deptLbl.text = dept as? String
        }
        if let id = UserDefaults.standard.value(forKey: UserDetails.userId){
            userID = (id as? String)!
            getCommissionAPICall(withID: userID)
        }
        
        //        self.noTaskLbl.isHidden = true
        self.reelsModelArray.removeAll()
        self.getpostAPICall(withType: "assigned_by_me")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
    }
    
    @IBAction func assignedBtnAct() {
        self.getpostAPICall(withType: "assigned_by_me")
        self.noTaskLbl.isHidden = true
//        UIView.animate(withDuration: 0.5) {
//            self.indvw.frame =  CGRect(x: self.assignBtn.frame.minX, y: self.assignBtn.frame.maxY + 5, width: self.assignBtn.frame.width, height: 3)
//        }
        
        self.assignLbl.isHidden = false
        self.stillLbl.isHidden = true
        self.doneLbl.isHidden = true
        self.approvedLbl.isHidden = true
    }
    
    @IBAction func stillBtnAct() {
        self.getpostAPICall(withType: "still_working")
        self.noTaskLbl.isHidden = true
//        UIView.animate(withDuration: 0.5) {
//            self.indvw.frame = CGRect(x: self.stillBtn.frame.minX, y: self.stillBtn.frame.maxY + 5, width: self.stillBtn.frame.width, height: 3)
//        }
        
        self.assignLbl.isHidden = true
        self.stillLbl.isHidden = false
        self.doneLbl.isHidden = true
        self.approvedLbl.isHidden = true
    }
    @IBAction func doneBtnAct() {
        self.getpostAPICall(withType: "done_success")
        self.noTaskLbl.isHidden = true
//        UIView.animate(withDuration: 0.5) {
//            self.indvw.frame = CGRect(x: self.donecBtn.frame.minX, y: self.donecBtn.frame.maxY + 5, width: self.donecBtn.frame.width, height: 3)
//        }
        
        self.assignLbl.isHidden = true
        self.stillLbl.isHidden = true
        self.doneLbl.isHidden = false
        self.approvedLbl.isHidden = true
    }
    
    @IBAction func doneApprovedBtnAct() {
        self.getpostAPICall(withType: "approved")
        self.noTaskLbl.isHidden = true
//        UIView.animate(withDuration: 0.5) {
//            self.indvw.frame = CGRect(x: self.doneApprovedBtn.frame.minX, y: self.doneApprovedBtn.frame.maxY + 5, width: self.doneApprovedBtn.frame.width, height: 3)
//        }
        
        self.assignLbl.isHidden = true
        self.stillLbl.isHidden = true
        self.doneLbl.isHidden = true
        self.approvedLbl.isHidden = false
    }
    
    func getCommissionAPICall(withID : String){
        
        APIModel.getRequest(strURL: BASEURL + COMMISSIONAPI + withID , postHeaders: headers as NSDictionary) { jsonData in
            let commissionResponse = try? JSONDecoder().decode(CommissionResponseModel.self, from: jsonData as! Data)
            if commissionResponse?.data != nil
            {
                self.commissionLbl.text = "$ " + (commissionResponse?.data?.doneCommission?.commission ?? "")
                
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
                
                let part2 = NSAttributedString(string: "Still working  $"  + "\n" +  self.stillworkingCommission)
                self.stillBtn.setAttributedTitle(part2, for: .normal)
                self.stillBtn.titleLabel?.textAlignment = .center
                
                let part3 = NSAttributedString(string: "Done Need to Check $"  + self.doneCommission)
                self.donecBtn.setAttributedTitle(part3, for: .normal)
                self.donecBtn.titleLabel?.textAlignment = .center
                
                let part4 = NSAttributedString(string: "Done Approved $" + "\n" + self.approvedCommission)
                self.doneApprovedBtn.setAttributedTitle(part4, for: .normal)
                self.doneApprovedBtn.titleLabel?.textAlignment = .center
            }
            
        } failure: { error in
            print(error)
        }
    }
    
    func getpostAPICall(withType : String){
        self.reelsModelArray.removeAll()
        APIModel.getRequest(strURL: BASEURL + GETREELSURL + withType , postHeaders: headers as NSDictionary) { _result in
            let getReelsResponseModel = try? JSONDecoder().decode(GetReelsResponseModel.self, from: _result as! Data)
            print(getReelsResponseModel?.data as Any)
            if getReelsResponseModel?.data != nil
            {
                self.reelsModelArray = (getReelsResponseModel?.data?.posts)!
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
            self.aulbumCW.reloadData()
            //
        } failure: { error in
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
        let videoUrl = URL(string: self.reelsModelArray[indexPath.row].videoURL!)
        item.thumbNailImageVW.image = getVideoThumbnail(url: videoUrl!)
        item.amountLbl.text = self.reelsModelArray[indexPath.row].commissionAmount ?? ""
        
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
        self.navigationController?.pushViewController(viewVidepVC, animated: true)
    }
    
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

