//
//  ServiceController.swift
//  Telugu Churches
//
//  Created by N@n!'$ Mac on 19/01/18.
//  Copyright © 2018 Mac OS. All rights reserved.
//

import Foundation
import UIKit
import KRProgressHUD
import SystemConfiguration

//MARK:-  Reachability Use For Checking Tha Internet Connection Available are not
var appDelegate = UIApplication.shared.delegate as! AppDelegate
let content_type = "application/json; charset=utf-8"
var serviceController = ServiceController()

class ServiceController: NSObject {
    
var window: UIWindow?
    
//MARK:- Post Request
    
    func postRequest(strURL:NSString,postParams:Encodable,postHeaders:NSDictionary,successHandler:@escaping( _ result:Any)->Void,failureHandler:@escaping (_ error:String)->Void) -> Void {
        if isConnectedToNetwork() == false {
            print("Please Check Internet")
            return
        }
        KRProgressHUD.show()
        let kAccess_token       : String = "kAccess_token"
        let kToken_type          = "kToken_type"
        let kClient_id           = "kClient_id"
        let kRefreshToken        = "kRefreshToken"
        let kTokenType           = "tokenType"

        let urlStr:NSString = strURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)! as NSString
//        let urlStr:NSString = strURL.addingPercentEscapes(using:String.Encoding.utf8.rawValue)! as NSString
        let url: NSURL = NSURL(string: urlStr as String)!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField:"Content-Type")
        request.addValue("application/json",forHTTPHeaderField:"Accept")
        if postHeaders["Authorization"] != nil  {
        }
    
        if let authToken = UserDefaults.standard.string(forKey: k_token) {
                    request.setValue("Bearer" + " " + authToken,forHTTPHeaderField: "Authorization")
                }
                
        do {
//            let data = try! JSONSerialization.data(withJSONObject:postParams, options:.prettyPrinted)
//            let dataString = String(data: data, encoding: String.Encoding.utf8)!
            let headerData = try! JSONSerialization.data(withJSONObject:postHeaders, options:.prettyPrinted)
            let headerDataString = String(data: headerData, encoding: String.Encoding.utf8)!
        
            print("Request Url :\(url)")
            print("Request Header Data :\(headerDataString)")
//            print("Request Data : \(dataString)")
//            request.httpBody = data
            request.httpBody = try JSONEncoder().encode(postParams)
            // do other stuff on success
        }
        catch {
            DispatchQueue.main.async(){
                print("JSON serialization failed:  \(error)")
            }
        }
        let task = URLSession.shared.dataTask(with: request as URLRequest) {(data, response, error) in
            KRProgressHUD.dismiss()
            //            print(data)
            //            print(response)
            //            print(error)
            DispatchQueue.main.async(){
                //  UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if response != nil {
                    // Response Status Code
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("statusCode:\(statusCode)")
                    if statusCode == 401 {
                        failureHandler("unAuthorized")
                    }
                    if statusCode == 500 {
                        print("failuer 1")
                        failureHandler("unAuthorized")
                    }
                    else if error != nil
                    {
                        print("error=\(String(describing: error))")
                        //        appDelegate.window?.makeToast(kRequestTimedOutMessage, duration:kToastDuration , position:CSToastPositionCenter)
                        return
                    }
                    else {
                        do {
                            let parsedData = try JSONSerialization.jsonObject(with: data!, options:.mutableContainers) as! [String:Any]
                            print(parsedData)
                            successHandler(data! as NSData)
                        } catch let error as NSError {
                            print("error=\(error)")
                            return
                        }
                    }
                }
            }
        }
        task.resume()
    }
   
///MARK:- Get Request
    
    func getRequest(strURL:String,postHeaders:NSDictionary,success:@escaping(_ result:Any)->Void,failure:@escaping(_ error:String) -> Void) {
        if isConnectedToNetwork() == false {
            print("Please Check Internet")
            return
        }
        KRProgressHUD.show()
        let fileUrl = NSURL(string: strURL)
        let request = NSMutableURLRequest(url: fileUrl! as URL)
        request.addValue(content_type, forHTTPHeaderField: "Content-Type")
        request.addValue(content_type, forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        if postHeaders["Authorization"] != nil  {
        }
        if let authToken = UserDefaults.standard.string(forKey: k_token) {
                    request.setValue("Bearer" + " " + authToken,forHTTPHeaderField: "Authorization")
                }
        do {
//            let data = try! JSONSerialization.data(withJSONObject:postParams, options:.prettyPrinted)
//            let dataString = String(data: data, encoding: String.Encoding.utf8)!
            let headerData = try! JSONSerialization.data(withJSONObject:postHeaders, options:.prettyPrinted)
            let headerDataString = String(data: headerData, encoding: String.Encoding.utf8)!
        
            print("Request Url :\(strURL)")
            print("Request Header Data :\(headerDataString)")
            
            // do other stuff on success
        }
        catch {
            DispatchQueue.main.async(){
                print("JSON serialization failed:  \(error)")
            }
        }
//        if let authToken = kUserDefaults.string(forKey: kAccess_token) {
//            if let tokenType = kUserDefaults.string(forKey: kTokenType) {
//                request.setValue(tokenType + " " + authToken,forHTTPHeaderField: "Authorization")
//            }
//        }
        let task = URLSession.shared.dataTask(with:request as URLRequest){(data,response,error) in
            DispatchQueue.main.async(){
                print(response as Any)
                KRProgressHUD.dismiss()
                if response != nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("statusCode:\(statusCode)")
                    if statusCode == 401 {
                        print("failuer 1")
                        failure("unAuthorized")
                    }
                    if statusCode == 500 {
                        print("failuer 1")
                        failure("unAuthorized")
                    }
                    if statusCode == 404 {
                        print("failuer 1")
                        failure("Enter Valid Credentials")
                    }
                    else if error != nil
                    {
                        print("failuer 1")
                        //   failure(error! as NSError)
                    }
                    else
                       {
                        print(statusCode)
                        do{
                            print("success 1")
                            let parsedData = try JSONSerialization.jsonObject(with: data!, options:.mutableContainers) as! [String:Any]
                            print(parsedData)
                            success(data! as NSData)
                        }
                        catch{
                            print("error=\(error)")
                            return
                        }
                    }
                }
                else{
                    print(error as Any)
                }
            }
        }
        task.resume()
    }
    
//    func showLoadingHUD(to_view: UIView) {
//        MBProgressHUD.showAdded(to: to_view, animated: true)
//        
//        //  hud.label.text = "Loading..."
//    }
//    func hideLoadingHUD(for_view: UIView) {
//        MBProgressHUD.hide(for: for_view, animated: true)
//    }
  
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
    
    
}

