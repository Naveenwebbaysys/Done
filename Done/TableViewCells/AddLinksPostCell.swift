//
//  AddLinksPostCell.swift
//  Done
//
//  Created by Sagar on 03/07/23.
//

import UIKit

class AddLinksPostCell: UITableViewCell {

    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
