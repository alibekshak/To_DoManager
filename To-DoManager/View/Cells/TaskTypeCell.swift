//
//  TaskTypeCell.swift
//  To-DoManager
//
//  Created by Apple on 06.09.2023.
//

import UIKit

class TaskTypeCell: UITableViewCell {
    
    @IBOutlet var typeTitel: UILabel!
    @IBOutlet var typeDescription: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
