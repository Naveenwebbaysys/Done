//
//  FiltersViewController.swift
//  Done
//
//  Created by Mac on 03/07/23.
//

import UIKit
import AlignedCollectionViewFlowLayout

class FiltersViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - outlet
    @IBOutlet weak var collectionviewDueDate: UICollectionView!
    @IBOutlet weak var collectionviewAssignee: UICollectionView!
    
    //MARK: - varible
    var arrDueDate: [String] = [String]()
    var arrSelectedDueDate: [String] = [String]()
    
//    var arrAssignee: [String] = [String]()
//    var arrSelectedAssignee: [String] = [String]()
    var arrAssignee: [List] = [List]()
    var arrSelectedAssignee: [List] = [List]()
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        arrDueDate = ["Latest Task","Old Task"]
//        arrAssignee = ["Gorak","Bucher","Slava","Benjamin","Galiynne","Alfonso"]
        collectionviewDueDate.register(UINib(nibName: "FilterListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterListCollectionViewCell")
        collectionviewAssignee.register(UINib(nibName: "FilterListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterListCollectionViewCell")
        let flowLayout = collectionviewDueDate?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        flowLayout?.horizontalAlignment = .left
        flowLayout?.verticalAlignment = .top
        flowLayout?.minimumInteritemSpacing = 10
        flowLayout?.minimumLineSpacing = 10

        flowLayout?.estimatedItemSize = .init(width: 80, height: 40)
        
    
    }
    

    
    //MARK: - UIButton Action
    @IBAction func backBrnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearBrnAction(){
        self.arrSelectedDueDate = ["Latest Task"]
        self.arrSelectedAssignee = [List]()
        self.collectionviewDueDate.reloadData()
        self.collectionviewAssignee.reloadData()
    }
    //MARK: - UICollectionView Delegate and Datasource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionviewDueDate{
            return arrDueDate.count
        }else{
            return self.arrAssignee.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell: FilterListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterListCollectionViewCell", for: indexPath)  as! FilterListCollectionViewCell
            cell.lblName.text = arrDueDate[indexPath.row]
            cell.viewBG.layer.cornerRadius = 20//cell.viewBG.bounds.height / 2
            cell.viewMark.layer.cornerRadius = cell.viewMark.bounds.height / 2
            if arrSelectedDueDate.contains(arrDueDate[indexPath.row]){
                cell.viewMark.isHidden = false
            }else{
                cell.viewMark.isHidden = true
            }
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let index = arrSelectedDueDate.firstIndex(of: arrDueDate[indexPath.row]) ?? -1
            if index >= 0{
                self.arrSelectedDueDate.remove(at: index)
            }else{
                self.arrSelectedDueDate = [arrDueDate[indexPath.row]]
            }
            self.collectionviewDueDate.reloadData()
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            let stTitle = arrDueDate[indexPath.row]
            let calWidth = stTitle.textWidth(30.0, textFont: UIFont.systemFont(ofSize: 16)) + 15
            return CGSize(width: calWidth, height: 30)
        
    }
    
    
    //VERTICAL
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    //HORIZONTAL
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
