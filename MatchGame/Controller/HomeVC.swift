//
//  HomeVC.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 20.11.2024.
//

import UIKit

class HomeVC: SuperVC, AudioVCDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var levelSelectionBackgroundView: BaseView!
    @IBOutlet weak var coinsMultiplierConstraint: NSLayoutConstraint!
    @IBOutlet weak var cointsMultiplierLabel: UILabel!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerSpacerView: UIView!
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var gameButtonStackView: UIStackView!
    @IBOutlet weak var levelNameLabel: UILabel!
    @IBOutlet weak var selectedLvlView: UIView!
    @IBOutlet private weak var childContainerView: UIView!
    @IBOutlet private var levelLabels: [UILabel]!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet private weak var gameTimerLabel: UILabel!
    
    @IBOutlet private weak var gameStackView: UIStackView!
    @IBOutlet private weak var menuButton: UIButton!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    var settingsPressedAction:(()->())?
//    var lvlSelectedMusic = AudioPlayerManager(type: .lvlSelected)
  //  var menuMusic = AudioPlayerManager(type: .menu)
    var audio: [AudioPlayerManager] = [
        .init(type: .lvlSelected),
        .init(type: .menu)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
        [view, levelSelectionBackgroundView].forEach { view in
            view?.backgroundColor = .init(patternImage: .backgroundLaminate)
        }
    }
    
    var selectedLevel:LevelModel.Level = .init(number: 0, difficulty: .easy) {
        didSet {
            levelLabels.forEach {
                $0.text = "\(self.selectedLevel.number)"
            }
            levelNameLabel.text = LevelModel.name(self.selectedLevel.number).title
        }
    }
    
    var lastUnlockedLevel:LevelModel.Level = .init(number: 0, difficulty: .easy)
    
    var primaryButtonAction:(()->())? {
        didSet {
            if self.primaryButton.isHidden && primaryButtonAction != nil {
                UIView.animate(withDuration: 0.3) {
                    self.primaryButton.isHidden = false
                }
            }
        }
    }

    var childNavVC:UINavigationController? {
        return children.first(where: {$0 is UINavigationController}) as? UINavigationController
    }
        
    func updateBalance(_ newValue:Int) {
        self.balanceLabel.text = "\(newValue)"
    }
    
    func updateTimer(_ newValue:Int) {
        gameTimerLabel.text = newValue.timeString
    }
    
    override func soundChanged() {
        super.soundChanged()
        childNavVC?.viewControllers.forEach({
            if let vc = $0 as? SuperVC {
                vc.soundChanged()
            }
        })
    }
    
    func updateCoinsMultiplier(time:Int, maxTimer:Int = 5000, xValue:Int) {
        let percent = xValue <= 0 ? 1 : CGFloat(time) / CGFloat(maxTimer)
        cointsMultiplierLabel.superview?.superview?.isHidden = xValue == 0
        cointsMultiplierLabel.text = "\(xValue)x"
        let width = cointsMultiplierLabel.superview?.superview?.frame.width ?? 0
        let newWidth = percent * width
        coinsMultiplierConstraint.constant = width - newWidth
        cointsMultiplierLabel.superview?.superview?.layoutIfNeeded()
        
    }
    
    func updateProgress(_ newValue:CGFloat) {
        var newValue = newValue
        if newValue > 1 {
            newValue = 1
        } else if newValue <= 0 {
            newValue = 0
        }
        
        progressWidthConstraint.constant = ((progressWidthConstraint.firstItem as? UIView)?.frame.width ?? 0) * newValue
        (progressWidthConstraint.firstItem as! UIView).layoutIfNeeded()
        (progressWidthConstraint.secondItem as! UIView).layoutIfNeeded()
    }
    
    @IBAction func primaryButtonPressed(_ sender: Any) {
        AudioBoxService().vibrate()
        if let action = primaryButtonAction {
            action()
        } else {
            self.childNavVC?.pushViewController(GameViewController.configure(self.selectedLevel)!, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                self.audio(.lvlSelected)?.play()
            })
        }
        
    }
    
    @IBAction func gameButtonsPressed(_ sender: UIButton) {
        AudioBoxService().vibrate()
        let vc = childNavVC?.viewControllers.first(where: {
            $0 is GameViewController
        }) as? GameViewController
        switch sender.tag {
        case 0:vc?.hammerPressed()
        case 1:vc?.freezeTimerPressed()
        case 2:vc?.randomizePressed()
        case 3:vc?.paintPressed()
        default:break
        }
    }
    
    @IBAction func settingPressed(_ sender: Any) {
        AudioBoxService().vibrate()
        if let action = settingsPressedAction {
            action()
        } else {
            childNavVC?.viewControllers.first(where: {$0 is LevelListVC})?.presentModally(MessageVC.configure(.settings({ [weak self] in
                self?.soundChanged()
            }), screenTitle: "Settings")!)
        }
    }
}

extension HomeVC {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        var hideGame:Bool = true
       
        if viewController is GameViewController {
            hideGame = false
        } else if viewController is LevelCompletionVC {
            menuButton.superview?.superview?.superview?.isHidden = true
        }
        let hideHeader = viewController is LevelCompletionVC
        let navigationVCZero = navigationController.viewControllers.count == 1
        let hideSpacer = navigationVCZero
        let hidePrimary = !navigationVCZero && primaryButtonAction == nil
        let settingsButtonName = viewController is GameViewController ? "pause" : "settings"
        UIView.animate(withDuration: 0.3, animations: {
            if self.gameStackView.isHidden != hideGame {
                self.gameStackView.isHidden = hideGame
                self.progressView.isHidden = hideGame
                self.gameButtonStackView.isHidden = hideGame
            }
            if self.headerSpacerView.isHidden != !hideSpacer {
                self.headerSpacerView.isHidden = !hideSpacer
            }
            if (self.menuButton.superview?.superview?.superview?.isHidden ?? false) != hideHeader {
                self.menuButton.superview?.superview?.superview?.isHidden = hideHeader
            }
            if self.primaryButton.isHidden != hidePrimary {
                self.primaryButton.isHidden = true
            }
            self.toggleLvlView(navigationVCZero, completion: {})
        })
        menuButton.setImage(.init(named: settingsButtonName), for: .normal)
        if navigationController.viewControllers.count == 1 {
            self.settingsPressedAction = nil
            self.primaryButtonAction = nil
        }
    }
}

extension HomeVC {
    
    func loadUI() {
        if childNavVC != nil {
            return
        }
        let vc = LevelListVC.configure()
        let nav = UINavigationController(rootViewController: vc!)
        nav.setNavigationBarHidden(true, animated: true)
        nav.delegate = self
        childContainerView.addSubview(nav.view)
        nav.view.addConstaits([.leading:0, .trailing:0, .top:0, .bottom:0])
        addChild(nav)
        nav.didMove(toParent: self)
        nav.definesPresentationContext = true
        
        selectedLvlView.shadow()
        self.updateCoinsMultiplier(time: 0, xValue: 0)
    }
    
    func toggleLvlView(_ show:Bool, completion:@escaping()->()) {
        UIView.animate(withDuration: 0.23, animations: {
            self.selectedLvlView.layer.move(.top, value: show ? 0 : (self.selectedLvlView.frame.maxY * -1))
        }, completion: { _ in
            completion()
        })
    }
    
    func disablePanelViews(_ disable:Bool) {
        if let stack = childContainerView.superview as? UIStackView {
            stack.arrangedSubviews.forEach {
                if $0 != childContainerView {
                    $0.isUserInteractionEnabled = !disable
                }
            }
        }
    }
}

extension HomeVC {
    static func configure() -> HomeVC? {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: HomeVC.self)) as? HomeVC
    }
}
