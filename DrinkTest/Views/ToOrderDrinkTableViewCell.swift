//
//  ToOrderDrinkTableViewCell.swift
//  DrinkTest
//
//  Created by Filip Ingr on 06/03/2020.
//  Copyright © 2020 Filip Ingr. All rights reserved.
//

import UIKit

protocol ToOrderDrinkTableViewCellDelegate {
    func remove(at index: Int)
}

class ToOrderDrinkTableViewCell: UITableViewCell {

    var delegate: ToOrderDrinkTableViewCellDelegate?
    
    @IBOutlet var drinkNameLabel: UILabel!
    @IBOutlet var removeButton: UIButton!
    var index: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.removeButton.layer.cornerRadius = 3
    }

    @IBAction func removeButtonAction() {
        if let idx = self.index {
            self.delegate?.remove(at: idx)
        }
    }
}
