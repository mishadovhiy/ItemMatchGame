//
//  UIViewController.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 06.12.2024.
//

import UIKit

extension UIViewController {
    func presentModally(_ vc:UIViewController) {
        if let topVC = self.presentedViewController {
            topVC.presentModally(vc)
        } else {
            self.present(vc, animated: true)
        }
    }
    
    func addLoadingView() {
        let view = LoadingVC.configure()
        
        self.view.addSubview(view!.view)
        view?.view.addConstaits([.leading:0, .top:0, .bottom:0, .trailing:0])
        addChild(view!)
        view?.didMove(toParent: self)
    }
    func removeLoadingView(completion:@escaping()->()) {
        UIView.animate(withDuration: 0.3) {
            let first =  self.children.first(where: {$0 is LoadingVC})
            first?.view.removeFromSuperview()
            first?.removeFromParent()
        } completion: { _ in
            completion()
        }

    }
}
