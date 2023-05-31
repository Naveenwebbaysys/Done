//
//  ViewController.swift
//  Done
//
//  Created by Mac on 25/05/23.
//

import UIKit
import KRProgressHUD


class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTf : UITextField!
    @IBOutlet weak var passwordTf : UITextField!
    @IBOutlet weak var eyeBtn : UIButton!
    @IBOutlet weak var emailerrorLbl : UILabel!
    @IBOutlet weak var passwordErrorLbl : UILabel!
    @IBOutlet weak var invalidLbl : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.emailTf.delegate = self
        self.passwordTf.delegate = self
        
        self.emailTf.text = "kranthiallaboina@gmail.com"
        self.passwordTf.text = "apple@123"
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.invalidLbl.isHidden = true
        
    }
    
    
    @IBAction func eyeBtnAction()
    {
        if eyeBtn.tag == 0 {
            self.passwordTf.isSecureTextEntry = false
            eyeBtn.tag = 1
        }
        else
        {
            self.passwordTf.isSecureTextEntry = true
            eyeBtn.tag = 0
        }
    }
    
    func loginAPICall()
    {
        let params = LoginRequestModel(email: self.emailTf.text!, password: self.passwordTf.text!, isEmployee: 1)
        serviceController.postRequest(strURL: "https://www.drrecommendations.com/api/user/login.php", postParams: params, postHeaders: ["" : ""]) { result in
            print(result)
            self.invalidLbl.isHidden = true
            self.showToast(message: "Login Success")

            let loginResponse = try? JSONDecoder().decode(LoginResponseModel.self, from: result as! Data)
            UserDefaults.standard.setValue(loginResponse?.accessToken ?? "", forKey: k_token)
            print(loginResponse?.accessToken ?? "")
            let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(homeVC, animated: true)
            
        } failureHandler: { error in
            print(error)
            
//            self.showToast(message: "Email or password invalid")
            self.invalidLbl.isHidden = false
        }
    }
    
    @IBAction func loginBtnAction()
    {
        
        self.emailerrorLbl.isHidden = self.emailTf.text != "" ? true : false
        self.passwordErrorLbl.isHidden = self.passwordTf.text != "" ? true : false
        
        if (self.emailTf.text!.isValidEmail() == false) {
            self.emailerrorLbl.isHidden = false
            self.emailerrorLbl.text = "  Please enter valid email"
            return
        }
        
        if self.emailTf.text != "" && self.passwordTf.text != ""
        {
           
            if Reachability.isConnectedToNetwork() == true
            {
                loginAPICall()
            }
            else
            {
                showToast(message: "Please check internet connection")
            }
        }
        
    }
    
    
}



extension LoginViewController : UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.invalidLbl.isHidden = true
    }
}
