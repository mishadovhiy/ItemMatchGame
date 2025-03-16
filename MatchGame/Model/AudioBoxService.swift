//
//  AudioBoxService.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 17.11.2024.
//

import UIKit
#if os(iOS)
import AudioToolbox
#endif
struct AudioBoxService {
    func vibrate() {
#if os(iOS)
        let action = {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async {
                action()
            }
        }
#endif
    }
}
