//
//  puzzleCell.swift
//  treasure
//
//  Created by pyhuang on 3/22/21.
//

import UIKit

class PuzzleCell: UITableViewCell{
    
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var puzzletypeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
