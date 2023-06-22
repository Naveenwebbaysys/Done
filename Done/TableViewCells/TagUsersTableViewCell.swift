//
//  TagUsersTableViewCell.swift
//  Done
//
//  Created by Mac on 06/06/23.
//

import UIKit

class TagUsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taguserNameLbl : UILabel!
    @IBOutlet weak var seletionBtn : UIButton!
    @IBOutlet weak var deptLbl : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
