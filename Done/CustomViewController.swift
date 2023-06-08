//
//  CustomViewController.swift
//  Done
//
//  Created by Mac on 31/05/23.
//

import UIKit

class CustomViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if selectedIndex == 2
        {
            
            
            self.openAlert(title: "Alert", message: "Are you sure want to Logout?",alertStyle: .alert,
                           actionTitles: ["Cancel", "Ok"],actionStyles: [.destructive, .default],
                           actions: [
                            {_ in
                                print("cancel click")
//                                self.selectedIndex = 0
                            },
                            {_ in
                                print("Okay click")
                                self.logoutAct()
                            }
                           ])
        }
        
    }
    
    func logoutAct()
    {
        UserDefaults.standard.removeObject(forKey: k_token)
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
}
