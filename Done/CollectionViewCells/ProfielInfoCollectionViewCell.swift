//
//  ProfielInfoCollectionViewCell.swift
//  Done
//
//  Created by Sagar on 12/07/23.
//

import UIKit

class ProfielInfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBG.layer.shadowColor = UIColor().HexToColor(hexString: "A3A3A3").cgColor
        viewBG.layer.shadowOffset = CGSize(width: 1, height: 1)
        viewBG.layer.shadowOpacity = 1.77
        viewBG.layer.shadowRadius = 1.0
        viewBG.clipsToBounds = false
        viewBG.layer.masksToBounds = true
        
        viewBG.layer.cornerRadius = 5
        viewBG.layer.masksToBounds = false
        viewBG.setNeedsLayout()
        viewBG.setNeedsDisplay()
    }

}
