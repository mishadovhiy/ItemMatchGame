//
//  MessageCollectionCell.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 21.11.2024.
//

import UIKit

class MessageCollectionCell: UICollectionViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var switchView: UISwitch!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var titleImageView: UIImageView!
    
    private var progressChanged:((CGFloat)->())?
    private var isOnChanged:((Bool)->())?
    var sliderDefaultValue:CGFloat = 0
    func set(title:String, imageName:String? = nil,
             isOn:Bool?, defaultValue:Int? = nil,
             isOnChanged:((_ newValue:Bool)->())? = nil,
             progressValue:Int? = nil,
             progressChanged:((_ newValue:CGFloat)->())? = nil) {
        self.progressChanged = progressChanged
        self.isOnChanged = isOnChanged
        titleLabel.text = title
        
        switchView.isOn = isOn ?? false
        switchView.isHidden = isOn == nil
        sliderView.isHidden = progressValue == nil || !(isOn ?? false)
        sliderView.value = Float(progressValue ?? 0)
        if let imageName = imageName,
           imageName != "" {
            titleImageView.image = .init(named: imageName)
        }
        titleImageView.isHidden = titleImageView.image == nil
        if isOn == nil {
            let subview = UIImageView(image: .utsideRed)
            
            titleLabel.superview?.insertSubview(subview, at: 0)
            subview.addConstaits([.leading:-5, .trailing:0, .top:0, .bottom:0])
            titleLabel.textColor = .text
        } else if let subview = titleLabel.superview as? UIStackView,
                  let imageView = subview.subviews.first(where: {$0 is UIImageView})
        {
            imageView.removeFromSuperview()
            titleLabel.textColor = .darkContainer
        }
    }
    
    @IBAction func isOnChanged(_ sender: Any) {
        let switchView = sender as? UISwitch
        isOnChanged?((sender as? UISwitch)?.isOn ?? false)
        sliderView.isHidden = !(switchView?.isOn ?? false)
        if switchView?.isOn ?? false {
            sliderView.value = Float(sliderDefaultValue)
        }

    }
    @IBAction func sliderChanged(_ sender: Any) {
        progressChanged?(CGFloat((sender as? UISlider)?.value ?? 0))
    }

}
