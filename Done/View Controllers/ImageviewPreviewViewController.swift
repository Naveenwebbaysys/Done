//
//  ImageviewPreviewViewController.swift
//  Done
//
//  Created by Sagar on 29/06/23.
//

import UIKit

class ImageviewPreviewViewController: UIViewController,UIScrollViewDelegate {
    
    //MARK: - Outlet
    @IBOutlet weak var imagevview: UIImageView!
    @IBOutlet weak var scrollviewImage: UIScrollView!
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var lblComment: UILabel!
    
    
    //MARK: - Varibale
    var selectedImageUrl:String?
    var selectedData:Data?
    var selectedImageComment:String?
    
    //MARK: - UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewComment.isHidden = true
        imagevview.translatesAutoresizingMaskIntoConstraints = false
        imagevview.contentMode = .scaleAspectFit
        
        scrollviewImage.minimumZoomScale = 1
        scrollviewImage.maximumZoomScale = 3
        scrollviewImage.showsHorizontalScrollIndicator = false
        scrollviewImage.showsVerticalScrollIndicator = false
        scrollviewImage.delegate = self
      
        if selectedData != nil{
            imagevview.image = UIImage(data: selectedData!)
        }else{
            imagevview.sd_setImage(with: URL.init(string: selectedImageUrl ?? ""), placeholderImage: nil, options: .highPriority) { (imge, error, cache, url) in
                if error == nil{
                    self.imagevview.image = imge
                }else{
                }
            }
        }
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapRecognizer)
        
        if selectedImageComment != nil{
            viewComment.isHidden = false
//            print(selectedImageComment)
            lblComment.text = selectedImageComment ?? ""
        }
    }
    
    
    //MARK: - UIButton Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if scrollviewImage.zoomScale == 1 {
            scrollviewImage.setZoomScale(2, animated: true)
        } else {
            scrollviewImage.setZoomScale(1, animated: true)
        }
    }
    
    //MARK: - UIScrollview Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imagevview
    }
    
    
    
    
}
