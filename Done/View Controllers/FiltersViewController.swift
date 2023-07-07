//
//  FiltersViewController.swift
//  Done
//
//  Created by Mac on 03/07/23.
//

import UIKit
import AlignedCollectionViewFlowLayout

protocol delegateFiltersVC{
    func setFilterValue(arrSelectedDueDate:[String],arrSelectedAssignee:[List])
}

class FiltersViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - outlet
    @IBOutlet weak var collectionviewDueDate: UICollectionView!
    @IBOutlet weak var collectionviewAssignee: UICollectionView!
    
    //MARK: - varible
    var arrDueDate: [String] = [String]()
    var arrSelectedDueDate: [String] = [String]()
    
    var arrAssignee: [List] = [List]()
    var arrSelectedAssignee: [List] = [List]()
    var delegate: delegateFiltersVC?
    
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
        
        let flowLayoutAssignee = collectionviewAssignee?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        flowLayoutAssignee?.horizontalAlignment = .left
        flowLayoutAssignee?.verticalAlignment = .top
        flowLayoutAssignee?.minimumInteritemSpacing = 10
        flowLayoutAssignee?.minimumLineSpacing = 10

        flowLayoutAssignee?.estimatedItemSize = .init(width: 80, height: 40)
        self.getAssignessApi()
    }
    
    //MARK: - Other Methods
    func getAssignessApi(){
//        KRProgressHUD.show()
        APIModel.optionsRequest(strURL: BASEURL + UPDATEPOSTAPI, postHeaders: headers as NSDictionary) { jsonData in
            let assigneeResponse = try? JSONDecoder().decode(AssigneeResponseModel.self, from: jsonData as! Data)
            self.arrAssignee = assigneeResponse?.assigneeList ?? [List]()
            self.collectionviewAssignee.reloadData()
        } failure: { error in
            
        }
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
    
    @IBAction func btnApplyAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        if arrSelectedDueDate.isEmpty{
            showToast(message: "Please select due date")
            return
        }
        self.delegate?.setFilterValue(arrSelectedDueDate: arrSelectedDueDate, arrSelectedAssignee: arrSelectedAssignee)
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
        if collectionView == collectionviewDueDate{
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
        }else{
            let cell: FilterListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterListCollectionViewCell", for: indexPath)  as! FilterListCollectionViewCell
            cell.lblName.text = self.arrAssignee[indexPath.row].firstName ?? ""
            cell.viewBG.layer.cornerRadius = 20//cell.viewBG.bounds.height / 2
            cell.viewMark.layer.cornerRadius = cell.viewMark.bounds.height / 2
            let isSelected = arrSelectedAssignee.contains { assignessData in
                (assignessData.firstName ?? "") == (self.arrAssignee[indexPath.row].firstName ?? "")
            }
            if isSelected{
                cell.viewMark.isHidden = false
            }else{
                cell.viewMark.isHidden = true
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionviewDueDate{
            let index = arrSelectedDueDate.firstIndex(of: arrDueDate[indexPath.row]) ?? -1
            if index >= 0{
                self.arrSelectedDueDate.remove(at: index)
            }else{
                self.arrSelectedDueDate = [arrDueDate[indexPath.row]]
            }
            self.collectionviewDueDate.reloadData()
        }else{
            let index = arrSelectedAssignee.firstIndex(where: {($0.firstName ?? "") == (self.arrAssignee[indexPath.row].firstName ?? "")})  ?? -1
            if index >= 0{
                self.arrSelectedAssignee.remove(at: index)
            }else{
                self.arrSelectedAssignee.append(self.arrAssignee[indexPath.row])
            }
            self.collectionviewAssignee.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionviewDueDate{
            let stTitle = arrDueDate[indexPath.row]
            let calWidth = stTitle.textWidth(30.0, textFont: UIFont.systemFont(ofSize: 16)) + 15
            return CGSize(width: calWidth, height: 30)
        }else{
            let stTitle = arrAssignee[indexPath.row].firstName ?? ""
            let calWidth = stTitle.textWidth(30.0, textFont: UIFont.systemFont(ofSize: 16)) + 15
            return CGSize(width: calWidth, height: 30)
        }
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
