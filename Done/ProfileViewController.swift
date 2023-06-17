//
//  LogoutViewController.swift
//  Done
//
//  Created by Mac on 09/06/23.
//

import UIKit
import iOSDropDown
import AVFoundation
import HMSegmentedControl

class ProfileViewController: UIViewController {
    @IBOutlet weak var segmentVW : UIView!
    @IBOutlet weak var aulbumCW : UICollectionView!
//    @IBOutlet weak var noTaskLbl : UILabel!
    var reelsModelArray = [Post]()
    private let itemsPerRow: CGFloat = 3
    @IBOutlet weak var segment : UISegmentedControl!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var deptLbl : UILabel!
    @IBOutlet weak var mailLbl : UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var commissionLbl : UILabel!
    var userID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.aulbumCW.delegate = self
        self.aulbumCW.dataSource = self
        self.aulbumCW.register(UINib(nibName: "AulbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AulbumCollectionViewCell")
        
        let layout = UICollectionViewFlowLayout()
             layout.scrollDirection = .vertical
             /// 4
             layout.minimumLineSpacing = 8
             /// 5
             layout.minimumInteritemSpacing = 4

             /// 6
        aulbumCW.setCollectionViewLayout(layout, animated: true)
        setupSegmentControl()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
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
   
    //MARK:- setupSegmentControl()
    func setupSegmentControl()
    {
        let segmentedControl = HMSegmentedControl(sectionTitles: ["Assigend","Still working", "Done"])
        let screenWidth = view.frame.width
        //        segmentedControl.frame = CGRect(x: (screenWidth - 200) / 2, y: navigiationView.bounds.midY , width: 200, height: 40)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentVW.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            //            segmentedControl.topAnchor.constraint(equalTo: navigiationView.bottomAnchor, constant: +20 ),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40.0),
            segmentedControl.widthAnchor.constraint(equalToConstant: self.segmentVW.frame.width),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: segmentVW.centerYAnchor)
        ])
        //        segmentedControl.centerYAnchor.constraint(equalTo: self.navigiationView.centerYAnchor).isActive = true
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.bottom
        segmentedControl.backgroundColor = .clear
        segmentedControl.selectionIndicatorColor = UIColor(named: "App_color")!
        segmentedControl.selectionIndicatorHeight = 2
        segmentedControl.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "ArialRoundedMTBold", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor(named: "App_color")!]
        segmentedControl.addTarget(self, action: #selector(segmentedControlChangedValue(sender:)), for: .valueChanged)
        //view.addSubview(segmentedControl)
    }
    
    @objc func segmentedControlChangedValue(sender: HMSegmentedControl)
    {
        if sender.selectedSegmentIndex == 0
        {
            self.getpostAPICall(withType: "assigned_by_me")
        }
        if sender.selectedSegmentIndex == 1
        {
            self.getpostAPICall(withType: "still_working")
        }
        if sender.selectedSegmentIndex == 2
        {
            self.getpostAPICall(withType: "done_success")
        }
    }
    
    func getCommissionAPICall(withID : String){
        
        APIModel.getRequest(strURL: BASEURL + COMMISSIONAPI + withID , postHeaders: headers as NSDictionary) { jsonData in
            
            let commissionResponse = try? JSONDecoder().decode(CommissionResponseModel.self, from: jsonData as! Data)
            
            if commissionResponse?.data != nil
            {
                self.commissionLbl.text = "$ " + (commissionResponse?.data?.doneCommission?.commission ?? "")
            }
            
        } failure: { error in
            
            
        }

        
    }
    
    func getpostAPICall(withType : String){
        self.reelsModelArray.removeAll()
        APIModel.getRequest(strURL: BASEURL + GETREELSURL + withType , postHeaders: headers as NSDictionary) { _result in
            let getReelsResponseModel = try? JSONDecoder().decode(GetReelsResponseModel.self, from: _result as! Data)
            print(getReelsResponseModel?.data as Any)
            if getReelsResponseModel?.data?.posts?.count != 0
            {
                self.reelsModelArray = (getReelsResponseModel?.data?.posts)!
                
            }
            else
            {
                print("No Reels found")
//                self.noTaskLbl.isHidden = false
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
                        {_ in print("cancel click")},
                        {_ in print("Okay click")
                            self.logoutAct()
                        }
                       ])
        
    }
    func logoutAct()
    {
        //        UserDefaults.standard.removeObject(forKey: k_token)
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
        
//        item.thumbNailImageVW.image = ROThumbnail.sharedInstance.getThumbnail(videoUrl!)
//        self.getThumbnailImageFromVideoUrl(url: videoUrl!) { (thumbNailImage) in
//            item.thumbNailImageVW.image = thumbNailImage
//        }
        item.thumbNailImageVW.image = getVideoThumbnail(url: videoUrl!)
        return item
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        /// 2
        return UIEdgeInsets(top: 1.0, left: 5.0, bottom: 1.0, right: 5.0)
    }

    /// 3
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        /// 4
        let lay = collectionViewLayout as! UICollectionViewFlowLayout
        /// 5
        let widthPerItem = collectionView.frame.width / 3 - lay.minimumInteritemSpacing
        /// 6
        return CGSize(width: widthPerItem - 5, height: 120)
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

    
    
    
    func getVideoThumbnail(url: URL) -> UIImage? {
        //let url = url as URL
        let request = URLRequest(url: url)
        let cache = URLCache.shared
        
        if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
            return image
        }
        
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 120, height: 120)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        var image: UIImage?
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            image = UIImage(cgImage: cgImage)
        } catch { }
        
        if let image = image, let data = image.pngData(), let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            let newImg = UIImage(data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
        
        return image
    }

    
}

