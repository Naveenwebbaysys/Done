//
//  CommentsTableViewCell.swift
//  Done
//
//  Created by Mac on 13/06/23.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLbl :  UILabel!
    @IBOutlet weak var commentLbl :  UILabel!
    @IBOutlet weak var dateLbl :  UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.commentLbl.cornerRadius = 10
        self.commentLbl.preferredMaxLayoutWidth = 240
//        commentLbl.translatesAutoresizingMaskIntoConstraints = false


        
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutIfNeeded()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
