//
//  MessageConfirmationCell.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 27.11.2024.
//

import UIKit

class MessageConfirmationCell:UICollectionViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    func set(title:String, description:String, image:UIImage? = nil) {
        descriptionLabel.text = description
        titleLabel.text = title
        mainImageView.image = image
        mainImageView.isHidden = mainImageView.image == nil
    }
}
