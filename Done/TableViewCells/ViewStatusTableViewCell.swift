//
//  ViewStatusTableViewCell.swift
//  Done
//
//  Created by Mac on 09/06/23.
//

import UIKit

class ViewStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl      : UILabel!
    @IBOutlet weak var statusLbl    : UILabel!
    @IBOutlet weak var dateLbl      : UILabel!
    @IBOutlet weak var commentsBtn  : UIButton!
    @IBOutlet weak var commentCountLbl : UILabel!
    @IBOutlet weak var lastMsgLbl   : UILabel!
    @IBOutlet weak var markBtn      : UIButton!
    @IBOutlet weak var approvedBtn  : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lastMsgLbl.minimumScaleFactor = 0.5 // Optional: Set a minimum scale factor for text truncation if needed
            
            // Set the desired minimum height
        lastMsgLbl.setContentHuggingPriority(.required, for: .vertical)
        lastMsgLbl.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
    
}
