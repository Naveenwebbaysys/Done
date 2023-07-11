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
        let groupListVC = storyboard?.instantiateViewController(withIdentifier: "GroupListViewController") as! GroupListViewController
        self.navigationController?.pushViewController(groupListVC, animated: true)
    }
    
    
    @IBAction func btnFeedBackAction(_ sender: UIButton) {
        let feedbackVC = storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        self.navigationController?.pushViewController(feedbackVC, animated: true)
    }
    

}
