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
    
    
    @IBAction func btnLogoutAction(_ sender: UIButton) {
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
