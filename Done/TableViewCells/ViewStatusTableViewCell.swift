//
//  ViewStatusTableViewCell.swift
//  Done
//
//  Created by Mac on 09/06/23.
//

import UIKit

class ViewStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var statusLbl : UILabel!
    @IBOutlet weak var dateLbl : UILabel!
    @IBOutlet weak var commentsBtn : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
    
}
