//
//  LevelCollectionCell.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import UIKit

class LevelCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var lockerView: UIView!
    @IBOutlet weak var selectionBackgroundView: UIView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet private weak var difficultiesStack: UIStackView!
    @IBOutlet private weak var levelNumLabel: UILabel!
    var selectedLevel:LevelModel.Level = .init(number: 0, difficulty: .easy)
    private var dificultyViews:[UIView]? {
        if self.superview == nil {
            return nil
        }
        if difficultiesStack.arrangedSubviews.count >= 3 {
            return difficultiesStack.arrangedSubviews
        } else {
            return nil
        }
    }
    private var didPress:((_ difficulty:LevelModel.Difficulty, _ lvl:Int)->())?
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.createDifficultyViews([])
    }
    
    func set(_ lvl:Int, selected:LevelModel.Level, user difficulties:[LevelModel.Difficulty], userLastLevel:Int, isLocked:Bool, pressed:@escaping(_ difficulty:LevelModel.Difficulty, _ lvl:Int)->()) {
        self.contentView.alpha = isLocked ? 0.6 : 1
        lockerView.isHidden = !isLocked
        self.isUserInteractionEnabled = !isLocked
        self.selectedLevel = selected
        self.levelNumLabel.text = LevelModel.name(lvl).title
        self.difficultiesStack.tag = lvl
        self.setSelected(selected.number == lvl)
        self.didPress = pressed
        self.selectedImageView.isHidden = selected.number != lvl
        setDifficultyScore(difficulties)
    }
    
    override func prepareForReuse() {
        self.setSelected(false, animated: false)
        super.prepareForReuse()
    }
    
    func setSelected(_ isSelected:Bool, animated:Bool = true, completion:@escaping()->() = {}) {
        let isSelected = self.isUserInteractionEnabled ? isSelected : false
        let animation = {
            if let imageView = self.levelNumLabel.superview?.superview?.superview?.subviews.first(where:{$0 is UIImageView}) as? UIImageView {
                imageView.shadow(opasity: isSelected ? 1 : 0, color: .black, radius: 3)
            }
            self.selectionBackgroundView.backgroundColor = isSelected ? .primaryBackground.withAlphaComponent(0.2) : .clear
            self.selectionBackgroundView.layer.cornerRadius = 10
            self.selectionBackgroundView.layer.borderWidth = isSelected ? 2 : 0
            self.selectionBackgroundView.layer.borderColor = UIColor.container.cgColor
            self.layer.zoom(value:isSelected ? 1.1 : self.isUserInteractionEnabled ? 1 : 0.7)
            self.contentView.layer.move(.top, value: isSelected ? -15 : (!self.isUserInteractionEnabled ? 75 : 0))
            self.isSelected = isSelected
        }
        if animated {
            UIView.animate(withDuration: 0.3) {
                animation()
            } completion: { _ in
                completion()
            }

        } else {
            animation()
            completion()
        }
    }
    
    private func createDifficultyViews(_ difficulties:[LevelModel.Difficulty]) {
        if dificultyViews != nil {
            return
        }
        LevelModel.Difficulty.allCases.forEach {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .center
            stack.distribution = .equalCentering
            stack.spacing = 4
            let topLabel = UILabel()
            stack.layer.name = $0.rawValue
            topLabel.text = $0.rawValue
            topLabel.textColor = .text
            topLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            topLabel.textAlignment = .center
          //  topLabel.backgroundColor = .red.withAlphaComponent(0.2)
            topLabel.isUserInteractionEnabled = true

           
            let imageStack = UIStackView()
            

            for _ in 0..<$0.number {
                let imageView:UIImageView = .init(image: .star)
                imageStack.addArrangedSubview(imageView)
            }
            
            [topLabel, imageStack].forEach {
                stack.addArrangedSubview($0)
            }
           // image.addConstaits([.height:40])
            topLabel.addConstaits([.height:20])
            self.difficultiesStack.addArrangedSubview(stack)
            stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(difficultyPressed(_:))))
        }
    }
    
    @objc private func difficultyPressed(_ sender:UITapGestureRecognizer) {
        self.setSelected(true) {
            let newValue:LevelModel.Difficulty = .init(rawValue: sender.view?.layer.name ?? "") ?? .easy
            self.selectedLevel.difficulty = newValue
            self.setDifficultyScore([newValue], animated: true) {
                self.didPress?((.init(rawValue: sender.view?.layer.name ?? "") ?? .easy), self.difficultiesStack.tag)
            }
            
        }
        
    }
    
    private func setDifficultyScore(_ difficulties:[LevelModel.Difficulty], animated:Bool = false, completion:@escaping()->() = {}) {

        dificultyViews?.forEach { view in
            let completed = self.isUserInteractionEnabled ? difficulties.contains(.init(rawValue: view.layer.name ?? "") ?? .easy) : false
           // view.layer.borderColor = UIColor.red.cgColor//completed ? UIColor.red.cgColor : UIColor.black.withAlphaComponent(0.1).cgColor
            //$0.layer.borderWidth = completed ? 3 : 1

            if let image = ((view as? UIStackView)?.arrangedSubviews.first(where: {$0 is UIStackView}) as? UIStackView)?.arrangedSubviews as? [UIImageView] {
                image.forEach {
                    $0.image = completed ? .star : .starInactive
                }
                
            }
            let action = {
                let isSelected = self.isUserInteractionEnabled ? (self.selectedLevel.number == self.difficultiesStack.tag && self.selectedLevel.difficulty.rawValue == view.layer.name) : false
                view.shadow(opasity: isSelected ? 1 : 0, color: .red)
                view.layer.move(.top, value: isSelected ? -10 : 0)
//                if self.selectedLevel.number == self.difficultiesStack.tag {
//                    view.layer.borderWidth = self.selectedLevel.difficulty.rawValue == view.layer.name ? 1 : 0
//                } else {
//                    view.layer.borderWidth = 0
//                   // $0.layer.opacity = 1
//                }
            }
            if animated {
                UIView.animate(withDuration: 0.3) {
                    action()
                } completion: { _ in
                    completion()
                }

            } else {
                action()
                completion()
            }
        }
    }
}
