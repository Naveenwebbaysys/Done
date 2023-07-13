//
//  TaskProofPerviewViewController.swift
//  Done
//
//  Created by Sagar on 13/07/23.
//

import UIKit

class TaskProofPerviewViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var collectionviewProof: UICollectionView!
    
    //MARK: - Variable
    var postID:Int?
    var employeeID:Int?
    var proofDesc : String?
    var proodDoc : String?
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionviewProof.register(UINib(nibName: "ProofMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProofMediaCollectionViewCell")
    }
    

    //MARK: - UIButton Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
  
    @IBAction func btnDoneAction(_ sender: UIButton) {
    }
}
