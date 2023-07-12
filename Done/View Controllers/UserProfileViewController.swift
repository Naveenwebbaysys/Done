//
//  UserProfileViewController.swift
//  Done
//
//  Created by Sagar on 11/07/23.
//

import UIKit

class UserProfileViewController: UIViewController,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Outlet
    @IBOutlet weak var collectionviewData: UICollectionView!
    @IBOutlet weak var constraintCollectionviewHeight: NSLayoutConstraint!
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionviewData.delegate = self
        self.collectionviewData.dataSource = self
        self.collectionviewData.register(UINib(nibName: "ProfielInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfielInfoCollectionViewCell")
        
        
    }
    
    //MARK: - UIButton Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfielInfoCollectionViewCell", for: indexPath) as! ProfielInfoCollectionViewCell
        if indexPath.row == 0{
            cell.lblTitle.text = "Projects\nFinished"
            cell.lblValue.text = "3"
        }else if indexPath.row == 1{
            cell.lblTitle.text = "Proiects\nPending"
            cell.lblValue.text = "2"
        }else if indexPath.row == 2{
            cell.lblTitle.text = "Projects\nOpen"
            cell.lblValue.text = "4"
        }else if indexPath.row == 3{
            cell.lblTitle.text = "Finished\nin 30 Days"
            cell.lblValue.text = "7"
        }else if indexPath.row == 4{
            cell.lblTitle.text = "Total\nEarning"
            cell.lblValue.text = "$1,200"
        }else if indexPath.row == 5{
            cell.lblTitle.text = "Projects\nNew"
            cell.lblValue.text = "4"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        /// 2
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let lay = collectionViewLayout as! UICollectionViewFlowLayout
        let widthPerItem = (collectionView.frame.width / 3) - lay.minimumInteritemSpacing
        
        let rows = ceil(CGFloat(6)/3.0)
        constraintCollectionviewHeight.constant = (rows * ((widthPerItem - 1) * 1.2)) + 10
        
        return CGSize(width: widthPerItem - 1, height: ((widthPerItem - 1) * 1.2) )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    
    
    
}
