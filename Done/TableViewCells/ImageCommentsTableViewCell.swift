//
//  ImageCommentsTableViewCell.swift
//  Done
//
//  Created by Sagar on 27/06/23.
//

import UIKit

class ImageCommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLbl :  UILabel!
    @IBOutlet weak var dateLbl :  UILabel!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var lblComment: PaddingLabel!
    @IBOutlet weak var btnVideoPlay: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
