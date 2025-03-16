//
//  SpinView.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import UIKit

class SpinView: UIView {

    var weelData:[String]!
    var size:CGSize!

    var wheelView:UIView?
    let linesColor = UIColor.container
    var rows:[UIView] = []

    func create(size:CGSize, wheelData:[String], completion:@escaping()->()) {
        self.size = size
        self.weelData = wheelData
        wheelView = .init()
        self.layer.move(.top, value: (UIApplication.shared.sceneKeyWindow?.frame.height ?? 0) * -1)
        self.addSubview(wheelView ?? UIView())
        self.wheelView?.addConstaits([.leading:0, .top:0, .trailing:0, .bottom:0], superView: self)
        self.wheelView?.layer.borderColor = linesColor.cgColor
        self.wheelView?.layer.cornerRadius = size.width / 2
        self.wheelView?.layer.borderWidth = 10
        self.wheelView?.layer.masksToBounds = true
        self.wheelView?.backgroundColor = .primaryBackground
        drawLines()
        self.toggleSpin(show: true, completion: completion)
        self.shadow()
    }

    func toggleSpin(show:Bool, completion:@escaping()->()) {
        let hideValue = (UIApplication.shared.sceneKeyWindow?.frame.height ?? 0) * -1
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
            self.layer.move(.top, value: show ? 0 : hideValue)
        }, completion: {_ in
            completion()
        })
    }
 
    var lines:[UIView] = []
    var firstLabels:[UILabel] = []
    var secondLabels:[UILabel] = []
    var spinLabels:[UILabel] {
        return firstLabels + secondLabels
    }
    
    func createRowLabel(isTop:Bool, window:CGFloat, superV:UIView, text:String) {
        let leabel = UILabel()
        leabel.text = text
        leabel.textAlignment = .center
        leabel.numberOfLines = 0
        leabel.rotate(rotation: isTop ? 0 : 180)
        leabel.font = .systemFont(ofSize: 60, weight: .black)
        leabel.textColor = .container
        superV.addSubview(leabel)
        leabel.addConstaits(isTop ? [.top:100, .centerX:0, .width:window] : [.bottom:-100, .centerX:0, .width:window], superView: superV)
        if isTop {
            firstLabels.append(leabel)
        } else {
            secondLabels.append(leabel)
        }
    }
    
    func drawLines() {
        let rotations:[CGFloat] = [0, 30, 60, 90, -60, -30]

        var n = 0
        var labelIndex = 0
        lines = rotations.compactMap({ rotation in
            let isLabelLine = !n.isMultiple(of: 2)
            

            let view = SpinSliceView()
            view.layer.name = "\(n)"
            view.backgroundColor = isLabelLine ? .clear : linesColor
            self.addSubview(view)
            view.addConstaits([.width:10, .height:self.size.height, .centerX:0, .centerY:0], superView: self)
            view.rotate(rotation: rotation)
            for i in 0..<2 {
                let redView = UIImageView(image: .star)
                redView.contentMode = .scaleAspectFit
                view.addSubview(redView)
                redView.addConstaits([.centerX:0, .width:30, .height:30])
                if i == 0 {
                    redView.addConstaits([.top:-15])
                } else {
                    redView.addConstaits([.bottom:15])
                }
                redView.shadow(color: .yellow)
            }
            let windwo = (UIApplication.shared.sceneKeyWindow?.frame.height ?? 0) - 40
            view.shadow()
            if isLabelLine {
                let text = (weelData[labelIndex], weelData[(weelData.count - 1) - labelIndex])

                labelIndex += 1
                createRowLabel(isTop: true, window: windwo,
                               superV: view, text: text.0)
                createRowLabel(isTop: false, window: windwo,
                               superV: view, text: text.1)
            }
            n += 1
            return view
        })
    }

    
    func change(isfirstLabels:Bool, newValue:Double) {
        let arr = isfirstLabels ? firstLabels : secondLabels
        arr.forEach { label in
            label.rotate(rotation: newValue)
        }
    }
    
    func toggleLabels(show:Bool) {
        spinLabels.forEach({ label in
            UIView.animate(withDuration: show ? 0.12 : 0.3, animations: {
                label.alpha = show ? 1 : 0
            })
        })
        
    }
}


class SpinSliceView: UIView {
    
    override var transform: CGAffineTransform {
        get {
            return super.transform
        }
        set {
            super.transform = newValue
        }
    }
    
}
