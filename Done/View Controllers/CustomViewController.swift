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
            UserDefaults.standard.set(0, forKey: "menuIndex")
        }
       
        if let i = UserDefaults.standard.value(forKey: "menuIndex")
        {
            print(i)
        }
        
        
        
    }
    

    
}
