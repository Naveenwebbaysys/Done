//
//  GroupListTableViewCell.swift
//  Done
//
//  Created by Sagar on 10/07/23.
//

import UIKit

class GroupListTableViewCell: UITableViewCell {

    //MARK: - other
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblGroupMemberList: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
