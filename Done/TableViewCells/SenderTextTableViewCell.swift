//
//  SenderTextTableViewCell.swift
//  Done
//
//  Created by Sagar on 06/07/23.
//

import UIKit

class SenderTextTableViewCell: UITableViewCell {

    @IBOutlet weak var viewChatBG: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnUserName: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.viewChatBG.setRoundCornersBY(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMinYCorner],cornerRaduis : 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
