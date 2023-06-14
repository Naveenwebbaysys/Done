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
        
        if selectedIndex == 1
        {
//            let postVC = self.storyboard?.instantiateViewController(withIdentifier: "RecordViewController") as! RecordViewController
//            self.navigationController?.pushViewController(postVC, animated: true)
        }
        
    }
    

    
}
