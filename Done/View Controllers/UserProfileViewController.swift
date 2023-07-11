//
//  UserProfileViewController.swift
//  Done
//
//  Created by Sagar on 11/07/23.
//

import UIKit

class UserProfileViewController: UIViewController {

    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - UIButton Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
