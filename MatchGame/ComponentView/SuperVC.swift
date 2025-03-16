//
//  SuperVC.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import UIKit

class SuperVC:UIViewController {
    
    func soundChanged() {
        audioVCProtocol?.audio.forEach({
            $0.updateValuem()
        })
    }
    
    
    var didDisappearAction:(()->())?

    private var audioVCProtocol:AudioVCDelegate? {
        self as? AudioVCDelegate
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioVCProtocol?.audio.forEach {
            $0.stop()
        }
        
        didDisappearAction?()
        didDisappearAction = nil
    }
    
    func audio(_ type:AudioPlayerManager.BundleAudio) -> AudioPlayerManager? {
        audioVCProtocol?.audio.first(where:{$0.type == type})

    }
}

extension UIViewController {
    func presentAlert(_ message:MessageContent, screenTitle:String, okButton:ButtonData? = nil) {
        self.presentModally(MessageVC.configure(.custom(.init(screenTitle: screenTitle, primaryButton: okButton, tableData: [
            .init(sectionTitle: "", cells: [
                .init(title: "", type: .message(message))
            ])
        ])), screenTitle: screenTitle)!)
    }
}
