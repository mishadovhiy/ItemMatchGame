//
//  LevelCompletionVC.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import UIKit
import SpriteKit

class LevelCompletionVC:SuperVC {
    @IBOutlet private weak var spinHolderView: UIView!
    @IBOutlet private weak var cointsLabel: UILabel!
    @IBOutlet private weak var wonLabel: UILabel!
    @IBOutlet private weak var skView: SKView!
    @IBOutlet private weak var spinButton: UIButton!

    private var viewModel:LevelCompletionViewModel?
    private var cointsPosition:CGPoint = .zero
    private var level:LevelModel.Level? = nil
    private var wonCoins:Int = 0
#warning("todo: array in superview")
    var backgroundSound = AudioPlayerManager(type: .lvlBackground.randomElement() ?? .lvlBackground1)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cointsLabel.alpha = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = .init()
        wonLabel.text = "You've \(wonCoins == 0 ? "not" : "") completed\n Level \(level?.number ?? 0)"
        cointsLabel.text = "\(wonCoins)"
        loadUI()
        if wonCoins >= 1 {
            SuccessSKScene.create(view: skView, type: .coloredConfety)
        } else {
            spinHolderView.isHidden = true
            spinButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCoinLabel()
        animateCoinLabel()
        if let navigation = self.navigationController,
           let parent = navigation.parent as? HomeVC
        {
            parent.primaryButtonAction = {
                self.donePressed()
            }
        }
    }
    
    private var coinLabel:UILabel? {
        UIApplication.shared.sceneKeyWindow?.subviews.first(where: {
            $0.layer.name == "coinLabel"
        }) as? UILabel
    }
    private var spinView:SpinView? {
        spinHolderView.subviews.first(where: {$0 is SpinView}) as? SpinView
    }
    
    private func donePressed() {
        self.view.isUserInteractionEnabled = false
        DispatchQueue(label: "db", qos: .userInitiated).async {
            var value = DB.db.profile.levels[self.level?.number ?? 0] ?? []
            value.append(self.level?.difficulty ?? .easy)
            var wonCoins = self.wonCoins
            let data = self.viewModel?.wheelData ?? []
            if data.count - 1 >= (self.viewModel?.woneIndex ?? 0) {
                let won = data[self.viewModel?.woneIndex ?? 0]
                wonCoins += Int(((Double(won) ?? 0) / 100) * Double(self.wonCoins))
            }
            DB.db.profile.score += (wonCoins + ((self.level?.number ?? 0) * (self.level?.difficulty.number ?? 0)))
            DB.db.profile.levels.updateValue(value, forKey: self.level?.number ?? 0)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction private func spinPressed(_ sender: Any) {
        spinPressed()
    }
}

fileprivate extension LevelCompletionVC {
    func loadUI() {
        loadSpinView()
    }
    
    func loadSpinView() {
        if spinView != nil {
            return
        }
        let wheelView = SpinView()
        spinHolderView.layer.zoom(value: 0.5)
        self.spinHolderView.addSubview(wheelView)
        let width = view.frame.height
        let size:CGSize = .init(width: width, height: width)
        wheelView.addConstaits([
            .top:-50, .centerX:0, .width:size.width, .height:size.height
        ])
        wheelView.create(size: size, wheelData: self.viewModel?.wheelData ?? []) {
            wheelView.rotate(rotation: self.viewModel?.weelRotationSortered ?? 0)
        }
    }
    
    func loadCoinLabel() {
        let label = UILabel(frame: .init(origin: cointsPosition, size: self.cointsLabel.frame.size))
        label.text = "\(wonCoins)"
        label.textAlignment = .center
        label.layer.name = "coinLabel"
        UIApplication.shared.sceneKeyWindow?.addSubview(label)
    }

    func animateCoinLabel() {
        let newFrame = self.cointsLabel.convert(self.cointsLabel.bounds, to: self.view)
        UIView.animate(withDuration: 3.0) {
            self.coinLabel?.frame.origin = newFrame.origin
            self.coinLabel?.frame.origin.x = newFrame.minX
        } completion: { _ in
            self.coinLabel?.removeWithAnimation {
                UIView.animate(withDuration: 0.3) {
                    self.cointsLabel?.alpha = 1
                }
            }
        }
    }
}

fileprivate extension LevelCompletionVC {
    func performRotation(isLast:Bool? = nil, completion:@escaping()->(), animationCompleted:(()->())? = nil) {
        guard let viewModel else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: isLast ?? false ? 1.8 : 0.20, repeats: false) { _ in
            completion()
        }
        
        let newRow = viewModel.selectedRow + 1 >= 6 ? 0 : viewModel.selectedRow + 1
        self.viewModel?.selectedRow = newRow
        let weelRotation = viewModel.weelRotationSortered
        
        if isLast != nil {
            let secs:[CGFloat] = isLast ?? false ? [2.5] : [0.2, 1]
            secs.forEach { sec in
                DispatchQueue.main.asyncAfter(deadline: .now() + sec, execute: {
                    self.viewModel?.weelDataIndexes.forEach { (key: CGFloat, value: Int) in
                        if self.spinView?.transform == CGAffineTransform(rotationAngle: (key * CGFloat.pi) / 180) {                            self.wheelScrollingOnData(last: sec == 2.5)
                        }
                    }
                })
            }
        }
        UIView.animate(withDuration: 5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
            self.spinView?.rotate(rotation: weelRotation)
        }, completion: { _ in
            animationCompleted?()
        })
    }

    func spinPressed() {
        if viewModel?.spinPressedValid() ?? false {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                self.viewModel?.apiDataIndex = Int.random(in: 0..<(self.viewModel?.spinMaxValueCount ?? 0))
            })
            self.performSpinPressed()
            spinView?.toggleLabels(show: true)
        }
    }
    
    func performSpinPressed() {
        guard let viewModel else {
            return
        }
        if !viewModel.spinPresenting {
            return
        }
        self.viewModel?.spinCount += 1
        performRotation(isLast:viewModel.spinCount == 1 ? nil : false, completion: {
            let i = viewModel.selectedRow == 5 ? 0 : viewModel.selectedRow + 1
            if (viewModel.rotationsSortedWheel.count - 1) >= i && viewModel.spinCount >= viewModel.spinsCointMax && viewModel.rotationsSortedWheel[i] == viewModel.rotationsSortedData[viewModel.apiDataIndex ?? 0] {
                self.performRotation(isLast:true, completion: {
                    self.viewModel?.woneIndex = viewModel.rotationToDataIndex
                    UIView.animate(withDuration: 0.3) {
                        self.spinButton.layer.zoom(value: 0.7)
                        self.spinButton?.alpha = 0
                    }
                }, animationCompleted: {
                    
                })
            } else {
                self.performSpinPressed()
            }
        })
    }
    
    func wheelScrollingOnData(last:Bool = false) {
        viewModel?.wheelRotateCalled = true
    }
}

extension LevelCompletionVC {
    static func configure(_ cointsPosition:CGPoint, level:LevelModel.Level?, woneAmount:Int) -> LevelCompletionVC? {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: LevelCompletionVC.self)) as? LevelCompletionVC
        vc?.level = level
        vc?.cointsPosition = cointsPosition
        vc?.wonCoins = woneAmount
        vc?.modalPresentationStyle = .overFullScreen
        return vc
    }
}
