//
//  ContactTableViewCell.swift
//  FinalProject
//
//  Created by Jesse Crocker on 2026-03-31.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var contactName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
