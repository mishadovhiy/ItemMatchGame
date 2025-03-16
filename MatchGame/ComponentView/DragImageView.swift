//
//  DragImageView.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 15.11.2024.
//

import UIKit

class DragImageView:UIImageView {
    var isAlpha: Bool = false
    var dropData:LevelModel.DropData {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.typeUpdated()
            }
        }
    }
    init(dropData: LevelModel.DropData) {
        self.dropData = dropData
        super.init(frame: .zero)
        self.typeUpdated()
    }
    
    func typeUpdated() {
        if dropData.type == .none {
            self.image = nil
            self.backgroundColor = .clear//dropData.type.color
        } else {
            self.image = dropData.type.image
            self.contentMode = .bottom
            print(self.image?.size, " terfwds")
            self.backgroundColor = .clear
            //dropData.type.color//.clear
        }
        self.contentMode = .scaleAspectFit
        self.tintColor = dropData.type.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


