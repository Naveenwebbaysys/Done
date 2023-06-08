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
        let created_on =  "2023-07-06"
        let created_on2 =  "2023-07-07"
 
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyy-dd-MM"
   // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: created_on)
        let yourDate1 = formatter.date(from: created_on)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "MMM d, yyyy"
        // again convert your date to string
        let myStringDate = formatter.string(from: yourDate!)
        let myStringDate1 = formatter.string(from: yourDate1!)

        print(myStringDate)
        
 
        
       

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
        let loginParams = LoginRequestModel(email: self.emailTf.text!, password: self.passwordTf.text!, isEmployee: 1)

        serviceController.postRequest(strURL: BASEURL + LOGINURL as NSString, postParams: loginParams, postHeaders: ["" : ""]) { result in
            print(result)
            self.invalidLbl.isHidden = true
            self.showToast(message: "Login Success")

            let loginResponse = try? JSONDecoder().decode(LoginResponseModel.self, from: result as! Data)
            UserDefaults.standard.setValue(loginResponse?.accessToken ?? "", forKey: k_token)
            headers.updateValue("Bearer " + (loginResponse?.accessToken)!, forKey: "Authorization")
            print(headers)
         
            print(loginResponse?.accessToken ?? "")
            
            let homeVC = self.storyboard?.instantiateViewController(identifier: "CustomViewController") as! CustomViewController
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
    
    func getDate( str : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: str) // replace Date String
    }
}



extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
}
