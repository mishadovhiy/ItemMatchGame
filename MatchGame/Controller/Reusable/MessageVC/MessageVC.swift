//
//  MessageVC.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 19.11.2024.
//

import UIKit

class MessageVC:SuperVC, UINavigationControllerDelegate {
    @IBOutlet weak var opacityBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var primaryButton: UIButton!
    var screenTitle:String = ""
    
    var type:ContentType = .settings({})

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needToggleHomeLvlView {
            homeVC?.toggleLvlView(false, completion: {})
        }
        homeVC?.disablePanelViews(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = screenTitle
        loadUI()
        secondaryButton.isHidden = true
//        primaryButton.isHidden = self.childVC?.screenData.primaryButton?.pressed == nil
        setupPrimaryButtonsStack()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2) {
            self.opacityBackgroundView.alpha = 0.23
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.view.removeBlur()
        if needToggleHomeLvlView {
            homeVC?.toggleLvlView(true, completion: {})
        }
        homeVC?.disablePanelViews(false)
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.opacityBackgroundView.alpha = 0
        } completion: { _ in
            super.dismiss(animated: flag, completion: completion)
        }

    }
    
    var homeVC: HomeVC? {
        (presentingViewController as? UINavigationController)?.parent as? HomeVC
    }
    private var needToggleHomeLvlView:Bool {
        (presentingViewController as? UINavigationController)?.topViewController is LevelListVC
    }
    
    var childVC:MessageContentVC? {
        (children.first(where: {
            if let nav = $0 as? UINavigationController,
               let _ = nav.viewControllers.last(where: {
                   $0 is MessageContentVC
               }) as? MessageContentVC
            {
                return true
            } else {
                return false
            }
        }) as? UINavigationController)?.viewControllers.last(where: {
            $0 is MessageContentVC
        }) as? MessageContentVC
    }
    
    func okPress() {
        let pressed = childVC?.screenData.primaryButton?.pressed ?? {
            self.dismiss(animated: true)
        }
        pressed()
        print(childVC?.screenData.primaryButton != nil ? "okopressed" : "okisnill")
    }
    
    @IBAction func closePressed(_ sender: Any) {
        AudioBoxService().vibrate()
        self.dismiss(animated: true)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        guard let sender = sender as? UIButton else {
            return
        }
        if sender.tag == 1 {
            if self.childVC?.navigationController?.viewControllers.count != 1 {
                self.childVC?.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        } else {
            AudioBoxService().vibrate()
            okPress()
        }
        
    }
}

fileprivate extension MessageVC {
    func loadUI() {
        loadChildContentVC()
        presentingViewController?.view.addBluer()
     //   let _ = opacityBackgroundView.addBluer(style:.dark)
    }
    
    func loadChildContentVC() {
        
        guard let vc = MessageContentVC.configure(screenData: self.type.screenData(db: DB.db, okPressed: okPress)) else { return }
        let nav = UINavigationController(rootViewController: vc)
        nav.delegate = self
        contentContainerView.addSubview(nav.view)
        nav.view.addConstaits([.left:0, .right:0, .top:0, .bottom:0, .height:250])
        nav.view.layer.cornerRadius = 9
        nav.view.layer.masksToBounds = true
        addChild(nav)
        nav.didMove(toParent: self)
        nav.navigationBar.tintColor = .text
    }
    
    func setupPrimaryButtonsStack(animated:Bool = false) {
        if let stack = primaryButton.superview as? UIStackView,
           !stack.arrangedSubviews.contains(where: {$0.isHidden == false})
        {
            self.setButtonsStackHidden(false, animated: animated)
            
        } else {
            self.setButtonsStackHidden(false, animated: animated)
        }
    }
    
    func setButtonsStackHidden(_ hidden:Bool, animated:Bool = true) {
        if (primaryButton.superview?.isHidden ?? true) != hidden {
            UIView.animate(withDuration: animated ? 0.3 : 0) {
                self.primaryButton.superview?.isHidden = hidden
            }
        }
    }
    
    func updateButtonTitles(_ data:MessageVC.ScreenData? = nil) {
        let data = data ?? childVC?.screenData
        primaryButton.setTitle(data?.primaryButton?.title ?? "OK", for: .normal)
    }
}

extension MessageVC {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let data = (viewController as? MessageContentVC)?.screenData
        let show = data?.primaryButton != nil
        [primaryButton, secondaryButton].forEach {
            $0?.isHidden = !show
        }
        updateButtonTitles(data)
        setupPrimaryButtonsStack(animated: true)
    }
}

extension MessageVC {
    typealias ContentType = MessageViewModel.ContentType
    typealias ScreenData = MessageViewModel.ScreenData
    
    static func configure(_ type:ContentType, screenTitle:String) -> MessageVC? {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: MessageVC.self)) as? MessageVC
        vc?.modalTransitionStyle = .coverVertical
        vc?.modalPresentationStyle = .overCurrentContext
        vc?.screenTitle = screenTitle
        vc?.type = type
        return vc
    }
}
