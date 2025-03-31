//
//  NewLevelListCell.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 31.03.2025.
//

import UIKit

class NewLevelListCell: UICollectionViewCell {
    
    @IBOutlet weak var lockerImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var level: Int = 0
    func set(_ lvl:Int, selected:LevelModel.Level, user difficulties:[LevelModel.Difficulty], userLastLevel:Int, isLocked:Bool, pressed:@escaping(_ difficulty:LevelModel.Difficulty, _ lvl:Int)->()) {
        self.level = lvl
        didPress = pressed
        backgroundImageView.image = LevelModel.LvlType(lvl).primaryLevelSelectionImage
        titleLabel.textColor = .init(resource: selected.number == lvl ? ColorResource.primaryBackground : ColorResource.container)
        titleLabel.text = LevelModel.LvlType(lvl).title
        self.backgroundColor = selected.number == lvl ? .container : .container.withAlphaComponent(0.2)
        buttonsStackView.arrangedSubviews.forEach { view in
            let isSelected = selected.number == lvl && view.tag + 1 == selected.difficulty.number
            view.layer.cornerRadius = 6
            view.layer.masksToBounds = true
            if let view = view as? UIButton {
                view.tintColor = (isSelected || selected.number != lvl) ? .black : .primaryBackground
                view.backgroundColor = isSelected ? .primaryBackground : .clear
            }
        }
    }
    
    private var didPress:((_ difficulty:LevelModel.Difficulty, _ lvl:Int)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        backgroundImageView.layer.zoom(value: 0.4)
        self.contentView.addBluer(insertAt: 1)
    }
    
    @IBAction private func levelPressed(_ sender: Any) {
        let difficulty:LevelModel.Difficulty
        guard let button = sender as? UIButton else {
            return
        }
        switch button.tag {
        case 0:difficulty = .easy
        case 1:difficulty = .medium
        case 2:difficulty = .hard
        default:difficulty = .easy
        }
        didPress?(difficulty, self.level)
    }
    
    
}
