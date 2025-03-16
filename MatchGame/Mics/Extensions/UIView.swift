//
//  UIView.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 15.11.2024.
//

import UIKit

extension UIView {
    func toImage() -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    var viewController:UIViewController? {
        var responder: UIResponder? = self
        var maxCount = 1000
        while responder != nil && maxCount >= 0 {
            maxCount -= 1
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func contains(_ touches: Set<UITouch>, inView:UIView) -> Bool {
        let frame = self.convert(self.bounds, to: inView)
        if let location = touches.first?.location(in: inView),
           frame.contains(location) {
            return true
        } else {
            return false
        }
    }
    
    func addConstaits(_ constants:[NSLayoutConstraint.Attribute:CGFloat], superView:UIView? = nil) {
        let superV = superView ?? self.superview
        guard let superV else {
            return
        }
        let layout = superV
        constants.forEach { (key, value) in
            let keyNil = key == .height || key == .width
            let item:Any? = keyNil ? nil : layout
            superV.addConstraint(.init(item: self, attribute: key, relatedBy: .equal, toItem: item, attribute: key, multiplier: 1, constant: value))
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func rotate(rotation:CGFloat) {
        self.transform = CGAffineTransform(rotationAngle: rotation * .pi / 180)
    }
    
    func removeWithAnimation(animation:CGFloat = 0.11, complation:(()->())? = nil) {
        UIView.animate(withDuration: animation, animations: {
            self.alpha = 0
        }) {
            if !$0 {
                return
            }
            self.isHidden = true
            
            if let com = complation {
                com()
            }
            self.removeFromSuperview()
        }
    }
    func hideWithAnimation(_ hidden:Bool, animation:CGFloat = 0.11) {
        UIView.animate(withDuration: animation, animations: {
            self.isHidden = hidden
        })
    }
}

extension UIView {
    func animateImage(like:Bool) {
        if let img = self.toImage() {
            var startX:CGFloat = -100
            let maxX:CGFloat = 130
            let count = Int.random(in: 6..<(Int.random(in: 8..<10)))
            let stepX:CGFloat = (maxX + (startX * CGFloat(-1))) / CGFloat(count)
            
            
            for i in 0..<count {
                let new = UIImageView()
                new.translatesAutoresizingMaskIntoConstraints = true
                self.addSubview(new)
                let widthMult:CGFloat = [0.5, 0.8, 1.0, 0.88, 0.9, 0.45].randomElement() ?? 0
                new.frame = .init(x: 0, y: 0, width: self.frame.size.width * widthMult, height: self.frame.size.height * widthMult)
                new.image = img
                new.alpha = 0.2
                new.layer.zPosition = -1
                new.tintColor = self.tintColor
                new.layer.zoom(value: 0.2)
                let y = startX
                startX += stepX
                let stepYCalc = stepX * CGFloat(i)
                let stepY = stepYCalc >= maxX ? (stepYCalc - maxX) : stepYCalc
                let plasX = [-10, -12, 2, 5, 10, -5, -8, -2, 8, 3].randomElement() ?? 0
                let plasY = [1, 4, 2, 5, 12, 10, 9, 12, 8, 3].randomElement() ?? 0
                UIView.animate(withDuration: 1.1, delay: 0, animations: {
                    new.frame.origin = .init(x: (y + CGFloat(plasX)), y: ((stepY + CGFloat(plasY)) * -1))
                }, completion:{ _ in
                    new.removeFromSuperview()
                })
                UIView.animate(withDuration: 0.5, delay: 0.6, animations: {
                    new.alpha = 0
                })
            }
            
        }
    }
    
    func shadow(opasity:Float = 0.6, color:UIColor? = nil, radius:CGFloat? = nil) {
        self.layer.shadowColor = (color ?? UIColor.container).cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = radius ?? 10
        self.layer.shadowOpacity = opasity
    }
    
    func createTouchView() {
        if self.subviews.first(where: {$0.layer.name == "createTouchView"}) != nil {
            return
        }
        let isBig = self.frame.width >= 50 ? true : false
        let size:CGSize = .init(width: isBig ? 64 : 44, height: isBig ? 64 : 44)
        let view = UIView(frame:.init(origin: .zero, size: size))
        let color = UIColor.text.withAlphaComponent(0.34)
        view.backgroundColor = color
        view.layer.cornerRadius = size.width / 2
        view.shadow(color: .text, radius: 15)
        view.layer.name = "createTouchView"
        self.addSubview(view)
        view.alpha = 0
        self.layer.masksToBounds = true
        view.isUserInteractionEnabled = false
    }
    
    func moveTouchView(show:Bool, at:(UITouch?, UIView)? = nil) {
        guard let view = self.subviews.first(where: {$0.layer.name == "createTouchView"}) else { return }
        if !show {
            view.removeWithAnimation(animation: 0.3)
        }
        view.alpha = show ? 1 : 0
        if let at = at {
            let touch = at.0?.location(in: at.1) ?? .zero
            UIView.animate(withDuration: show ? 0 : 0.3) {
                view.frame.origin = .init(x: touch.x - 23, y: touch.y - 18)
            }
        }
    }
    
    func removeTouchView() {
        guard let view = self.subviews.first(where: {$0.layer.name == "createTouchView"}) else { return }
        view.removeFromSuperview()
    }
    
    private static let blurLayerName = "mainBlur"
    
    func addBluer(style:UIBlurEffect.Style = (.init(rawValue: -1000) ?? .regular), insertAt:Int? = nil) {
        let blurEffect = UIBlurEffect(style: style)
        let bluer = UIVisualEffectView(effect: blurEffect)
        let vibracity = UIVisualEffectView(effect: blurEffect)
        bluer.contentView.addSubview(vibracity)
        let constaints:[NSLayoutConstraint.Attribute : CGFloat] = [.leading:0, .top:0, .trailing:0, .bottom:0]
        vibracity.addConstaits(constaints)
        bluer.layer.name = UIView.blurLayerName
        if let at = insertAt {
            self.insertSubview(bluer, at: at)
        } else {
            self.addSubview(bluer)
        }
        
        bluer.addConstaits(constaints)
    }
    
    func removeBlur() {
        subviews.forEach {
            if $0.layer.name == UIView.blurLayerName {
                $0.removeFromSuperview()
            }
        }
    }
    
}
