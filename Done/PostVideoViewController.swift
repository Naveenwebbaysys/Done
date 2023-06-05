//
//  SnapVideoViewController.swift
//  Done
//
//  Created by Mac on 02/06/23.
//

import UIKit
import AVFoundation
import AWSS3
import AWSCore
import KRProgressHUD

class PostViewController: UIViewController {

    var placeholder = "Decription.."
    var recordVideoURL = ""
    var uuid = ""
    var awsS3Url = ""
    @IBOutlet weak var  descriptionTV : UITextView!
    @IBOutlet weak var  commissionTypeVW : UIStackView!
    @IBOutlet weak var  commissionTypeLbl : UILabel!
    @IBOutlet weak var  increseBtn : UIButton!
    @IBOutlet weak var  decreaseBtn : UIButton!
    
    @IBOutlet weak var  restrictVW : UIStackView!
    @IBOutlet weak var  assigenedBtn : UIButton!
    @IBOutlet weak var  everyOneBtn : UIButton!
    @IBOutlet weak var  restrictLbl : UILabel!
    @IBOutlet weak var  commissionTF : UILabel!
    
    @IBOutlet weak var  dateLbl : UILabel!
    @IBOutlet weak var  amountTF : UITextField!
    @IBOutlet weak var  linksTF : UITextField!
    
    var tagPeoples1 =  [String]()
    let addLinks1 = [String]()
    let tags1 =  [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        awss3Setup()
        tagPeoples1.append("13")
        
        descriptionTV.text = placeholder
        descriptionTV.textColor = .lightGray
        descriptionTV.delegate = self
        
        commissionTypeLbl.text = "Increase"
        restrictLbl.text = "Everyone"
    
    }
    
    
    @IBAction func commissiondropBtnAction(){
        
        commissionTypeVW.isHidden = false
    }
    
    @IBAction func restrictionBtnAction(){
        
        restrictVW.isHidden = false
    }
    
    
    @IBAction func increseBtnAction(){
        
        commissionTypeVW.isHidden = true
        commissionTypeLbl.text = "Increase"
        
        
        
    }
    
    @IBAction func decreaseAction(){
        
        commissionTypeVW.isHidden = true
        commissionTypeLbl.text = "Decrease"
    }
    @IBAction func assigenedBtnAction(){
        
        restrictVW.isHidden = true
        restrictLbl.text = "Assigned People"
    }
    
    @IBAction func everyOneBtnAction(){
        
        restrictVW.isHidden = true
        restrictLbl.text = "Everyone"
    }
    
    @IBAction func postBtnAction(){
        uploadVideoToS3Server(filePath: recordVideoURL)
    }
  
}

extension PostViewController {
    
    func awss3Setup ()
    {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .USWest1, credentialsProvider: credentialsProvider)
        
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: AWSS3TransferUtilityConfiguration(),
            forKey: "S3TransferUtilityKey"
        )
    }
    
    func uploadVideoToS3Server (filePath : String)
    {
        KRProgressHUD.show()
        let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "S3TransferUtilityKey")
        let bucketName = BUCKET_NAME
        let fileURL = URL(fileURLWithPath: filePath)
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.progressBlock = { task, progress in
            // Handle progress updates if needed
        }
        uuid = UUID().uuidString
        
        transferUtility?.uploadFile(
            fileURL,
            bucket: bucketName,
            key: "iosdone/" + uuid + ".mp4",
            contentType: "video/mp4",
            expression: uploadExpression,
            completionHandler: { [self] task, error in
                KRProgressHUD.dismiss()
                if let error = error {
                    // Handle the error
                    print("Upload error: \(error.localizedDescription)")
                    self.showToast(message: error.localizedDescription)
                    return
                }
                // The upload task completed successfully
                print("Upload completed successfully")
                
                // You can access the uploaded file URL using the task's response property
                if let response = task.response {
                    let fileURL = response.url
                    print("Uploaded file URL: \(String(describing: fileURL))")
                    print("Base URL: " + "https://d1g0ba8hbbwly8.cloudfront.net")
                    print("Split URL: \(String(describing: response.url?.relativePath))")
                    awsS3Url = SERVERURL + response.url!.relativePath
                    createPostAPICall(str: awsS3Url)
                }
            }
        )
    }
    
    func createPostAPICall(str : String)
    {
        var descText = ""
        var commAmount =  ""
        var commType = ""
        var restType = ""
        DispatchQueue.main.async { [self] in
            descText = self.descriptionTV.text
             commAmount =  amountTF.text ?? ""
             commType = commissionTypeLbl.text ?? ""
             restType = restrictLbl.text ?? ""
        }
        
        
        
        print(descText)
        print(commAmount)
        print(commType)
        print(restType)
        
        let postparams = PostRequestModel(videoURL: str, tagPeoples: tagPeoples1, addLinks: addLinks1, tags: tags1, videoRestriction: restType, description: descText, assignedDate: "2023-06-05", commissionType: commType, commissionAmount: commAmount, dueDate: "2023-07-06")
        let jsonData = try! JSONEncoder().encode(postparams)
        let params11 = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
        print(params11!)
  
        print(postparams.convertToString as Any)

        serviceController.postRequest(strURL: BASEURL + CREATEPOSTURL as NSString , postParams: postparams, postHeaders: headers as NSDictionary) { result in
            print(result)
            let postResponse = try? JSONDecoder().decode(PostResponseModel.self, from: result as! Data)
            if postResponse?.status == true
            {
                
                
                let story = UIStoryboard(name: "Main", bundle:nil)
                let vc = story.instantiateViewController(withIdentifier: "CustomViewController") as! CustomViewController
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            else
            {
                print("Error")
            }

        } failureHandler: { error in
            print(error)
            
//            self.showToast(message: "Email or password invalid")
            
        }

    }
}


extension Encodable {
    var convertToString: String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}



extension PostViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    if descriptionTV.textColor == .lightGray {
        descriptionTV.text = ""
        descriptionTV.textColor = .black
    }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
    descriptionTV.text = "Decription.."
    textView.textColor = UIColor.lightGray
    placeholder = ""
    } else {
    placeholder = descriptionTV.text
    }
    }
    
    func textViewDidChange(_ textView: UITextView) {
    placeholder = descriptionTV.text
    }
}
