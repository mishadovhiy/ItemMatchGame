//
//  DragImageView.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 15.11.2024.
//

import UIKit

class DragImageView:UIImageView {
    var isAlpha: Bool = false
    var dropData:String {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.typeUpdated()
            }
        }
    }
    init(dropData: String) {
        self.dropData = dropData
        super.init(frame: .zero)
        self.typeUpdated()
    }
    
    func typeUpdated() {
        if dropData == "" {
            self.image = nil
            self.backgroundColor = .clear//dropData.type.color
        } else {
            self.image = .init(named: dropData)
            self.contentMode = .bottom
            print(self.image?.size, " terfwds")
            self.backgroundColor = .clear
            //dropData.type.color//.clear
        }
        if dropData != "" && image == nil {
            dropData = ""
        }
        self.contentMode = .scaleAspectFit
        self.tintColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


