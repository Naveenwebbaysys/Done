//
//  Navigations.swift
//  Done
//
//  Created by Mac on 26/06/23.
//

import Foundation
import UIKit

extension  UIViewController {
    
    func navToPostVc()
    {
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        self.navigationController?.pushViewController(postVC, animated: true)
    }

    func navToHomeVC()
    {
        let homeVC = self.storyboard?.instantiateViewController(identifier: "CustomViewController") as! CustomViewController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    func navToViewStatus(index : Int)
    {
        
    }
    
    func setRootVC()
    {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = mainStoryboard.instantiateViewController(withIdentifier: "CustomViewController") as! CustomViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        UIApplication.shared.windows.first?.rootViewController = nav
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func navToTagUserVC()
    {
        
    }
    
}
