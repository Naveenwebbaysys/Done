//
//  SplashScreenViewController.swift
//  Done
//
//  Created by Mac on 07/06/23.
//

import UIKit

class SplashScreenViewController: UIViewController {

    var userId = String()
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        userId = UserDefaults.standard.string(forKey: k_token) ?? ""
        
        if userId != ""
        {
            self.navigationToHome()
        }
        else
        {
            self.navigationLogin()
        }
    }
    
    //MARK:- navigationToHome()
    func navigationToHome()
    {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomViewController") as! CustomViewController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    //MARK:- navigationLogin()
    func navigationLogin()
    {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }

}
