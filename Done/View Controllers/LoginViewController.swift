//
//  ViewController.swift
//  Done
//
//  Created by Mac on 25/05/23.
//

import UIKit
import KRProgressHUD
import Foundation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTf : UITextField!
    @IBOutlet weak var passwordTf : UITextField!
    @IBOutlet weak var eyeBtn : UIButton!
    @IBOutlet weak var emailerrorLbl : UILabel!
    @IBOutlet weak var passwordErrorLbl : UILabel!
    @IBOutlet weak var invalidLbl : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTf.delegate = self
        self.passwordTf.delegate = self
        self.emailTf.text = "kranthiallaboina@gmail.com"
        self.passwordTf.text = "apple@123"
        
//                self.emailTf.text = "Gorakrao@gmail.com"
//                self.passwordTf.text = "gorakrao"

        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        print(localTimeZoneIdentifier)
//        checkDate()
   
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
        
        APIModel.postRequest(strURL: BASEURL + LOGINURL as NSString, postParams: loginParams, postHeaders: ["" : ""]) { [self] result in
            print(result)
            self.invalidLbl.isHidden = true
            self.showToast(message: "Login Success")
            let loginResponse = try? JSONDecoder().decode(LoginResponseModel.self, from: result as! Data)
            UserDefaults.standard.setValue(loginResponse?.accessToken ?? "", forKey: k_token)
            UserDefaults.standard.setValue(loginResponse?.accessToken ?? "", forKey: k_token)
            headers.updateValue("Bearer " + (loginResponse?.accessToken)!, forKey: "Authorization")
            print(headers)
            profileAPICall(token: (loginResponse?.accessToken)!)
            print(loginResponse?.accessToken ?? "")
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
    
    func profileAPICall(token : String)
    {
        APIModel.getRequest(strURL: BASEURL + PROFILE, postHeaders:  headers as NSDictionary) { result in
            let profileResponseModel = try? JSONDecoder().decode(ProfileResponseModel.self, from: result as! Data)
            UserDefaults.standard.setValue(profileResponseModel?.employee?.id ?? "" , forKey: UserDetails.userId)
            let fullName = (profileResponseModel?.employee?.firstName ?? "")! + " " + (profileResponseModel?.employee?.lastName ?? "")!
            UserDefaults.standard.setValue(fullName , forKey: UserDetails.userName)
            UserDefaults.standard.setValue(profileResponseModel?.employee?.department  , forKey: UserDetails.deptName)
            UserDefaults.standard.setValue(profileResponseModel?.employee?.email  , forKey: UserDetails.userMailID)
            UserDefaults.standard.setValue(profileResponseModel?.employee?.id  , forKey: UserDetails.userId)
            self.navToHomeVC()
        } failure: { error in
            print(error)
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
    
    func checkDate()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let givenDateString = "2023-06-14 06:31:27"
        let givenDate = dateFormatter.date(from: givenDateString)!
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        if calendar.isDateInToday(givenDate) {
            dateFormatter.dateFormat = "HH:mm:ss"
            let currentTimeString = dateFormatter.string(from: givenDate)
            print("Today, \(currentTimeString)")
        } else {
            let formattedDateString = dateFormatter.string(from: givenDate)
            print(formattedDateString)
        }
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
