//
//  MenuListViewController.swift
//  Done
//
//  Created by Sagar on 08/07/23.
//

import UIKit

class MenuListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - UIButton Action
    @IBAction func btnNewGroupsAction(_ sender: UIButton) {
        let postVC = storyboard?.instantiateViewController(withIdentifier: "GroupCreateViewController") as! GroupCreateViewController
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    

}
