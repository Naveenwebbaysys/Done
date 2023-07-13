//
//  FeedbackViewController.swift
//  Done
//
//  Created by Sagar on 11/07/23.
//

import UIKit
import MGStarRatingView

class FeedbackViewController: UIViewController, UITextViewDelegate {

    //MARK: - Outlet
    @IBOutlet weak var txtviewFeedBack: UITextView!
    @IBOutlet weak var scrollviewBG: UIScrollView!
    @IBOutlet weak var viewRating: StarRatingView!
    
    //MARK: - Variable
    var postID:Int?
    var employeeID:Int?
    
    //MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        FeedbackVM.shared.controller = self
        txtviewFeedBack.text = "Enter a feedback"
        txtviewFeedBack.textColor = UIColor.lightGray
    }
    
    //MARK: - UIButton action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        FeedbackVM.shared.addTaskReview(postID: postID ?? 0, employeeID: employeeID ?? 0, taskStatus: "done_suceess", review: txtviewFeedBack.text! == "Enter a feedback" ? "" : txtviewFeedBack.text!, rating: "\(Int(viewRating.current))")
    }
    
    //MARK: - UITextview delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter a feedback"
            textView.textColor = UIColor.lightGray
        }
    }
}
