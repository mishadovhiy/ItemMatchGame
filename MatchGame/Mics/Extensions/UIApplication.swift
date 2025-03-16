//
//  UIApplication.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 15.11.2024.
//

import UIKit

extension UIApplication {
    var sceneKeyWindow:UIWindow? {
        if !Thread.isMainThread {
            print("mainthreaderror")
        }
        if #available(iOS 13.0, *) {
            let scene = self.connectedScenes.first(where: {
                let window = $0 as? UIWindowScene
                return window?.activationState == .foregroundActive && (window?.windows.contains(where: { $0.isKeyWindow && $0.layer.name == AppDelegate.shared?.windowID}) ?? false)
            }) as? UIWindowScene
            return scene?.windows.last(where: {$0.isKeyWindow }) ?? ((self.connectedScenes.first as? UIWindowScene)?.windows.first)
        } else {
            return UIApplication.shared.keyWindow
        }
        
    }

}
