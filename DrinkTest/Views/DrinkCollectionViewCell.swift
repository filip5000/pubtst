//
//  DrinkCollectionViewCell.swift
//  DrinkTest
//
//  Created by Filip Ingr on 06/03/2020.
//  Copyright © 2020 Filip Ingr. All rights reserved.
//

import UIKit

class DrinkCollectionViewCell: UICollectionViewCell {

    @IBOutlet var drinkNameLabel: UILabel!
    @IBOutlet var bgView: UIView!
    @IBOutlet var freeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 15
        freeLabel.layer.cornerRadius = 4
        freeLabel.clipsToBounds = true
        freeLabel.isHidden = true
    }
    
    func setFreeLabel(visible: Bool) {
        freeLabel.isHidden = visible
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        freeLabel.isHidden = true
    }
}
