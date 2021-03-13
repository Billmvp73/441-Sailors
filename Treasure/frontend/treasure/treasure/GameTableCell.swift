//
//  GameTableCell.swift
//  treasure
//
//  Created by pyhuang on 3/12/21.
//

import UIKit

class GameTableCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var gamenameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    var renderGames:(()->Void)?
    @IBAction func mapTapped(_ sender: Any) {
        self.renderGames?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
