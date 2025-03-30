//
//  BaseButton.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 19.11.2024.
//

import UIKit
class BaseView:UIView {
    @IBInspectable var borderWidth:CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor:UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderRadius:CGFloat = .zero {
        didSet {
            layer.cornerRadius = borderRadius
        }
    }
}
class BaseButton:UIButton {
    var touchAction:((_ touchesBegun:Bool)->())?

    @IBInspectable var cornerRadius:CGFloat = 0
    @IBInspectable var refreshOnPress:Bool = false

    @IBInspectable var borderWidth:CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor:UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    private var activityIndicatorView:UIActivityIndicatorView? {
        return subviews.first(where: {$0 is UIActivityIndicatorView}) as? UIActivityIndicatorView
    }
    //check if added from storyboard
    //set height, width
    var data:ButtonData? {
        didSet {
            if self.superview != nil {
                dataUpdated()
            }
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init?(data:ButtonData?) {
        self.init(frame: .zero)
        self.data = data
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateUI()
        if self.superview == nil {
            return
        }
        loadUI()
        if let image = image(for: .normal) {
            self.setImage(image, for: .normal)
        }
    }
    
    override var isEnabled: Bool {
        get {
            super.isEnabled
        }
        set {
            super.isEnabled = newValue
            if newValue {
                refresh(start: !newValue)
            }
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
//        self.setAttributedTitle(.init(string: title ?? "", attributes: [
//            .font:(self.type?.properties.font ?? .default(ofSize: 17, weight: .semibold))!
//        ]), for: state)
        super.setTitle(title, for: state)
    }
    
    
    func refresh(start:Bool, completion:(()->())? = nil) {
        guard let _ = self.activityIndicatorView else {
            if !start {
                return
            }
            loadrefreshControll()
            refresh(start: start, completion: completion)
            return
        }
        isUserInteractionEnabled = !start
     //   activityIndicatorView?.backgroundColor = self.backgroundColor?.darker().withAlphaComponent(0.2)
        if start {
            self.activityIndicatorView?.layer.zoom(value: 0.8)
            self.activityIndicatorView?.startAnimating()
        }
        let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.activityIndicatorView?.alpha = start ? 1 : 0
            self.activityIndicatorView?.layer.zoom(value: start ? 1 : 0.8)
        }
        animation.addCompletion { _ in
            if !start {
                self.activityIndicatorView?.stopAnimating()
            }
            completion?()
        }
        animation.startAnimation()
    }
    
    // MARK: - IBAction
    private func performButtonPressed() {
//        if let viewController, type?.containsType(.close) ?? false {
//            let data = self.data
//            viewController.dismiss(animated: true, completion: {
//                data?.pressed()
//            })
//        } else {
            data?.pressed?()
//        }
    }
    
    // MARK: - IBAction
    @objc private func buttonPressed(_ sender: UIButton) {
        if refreshOnPress {
            self.refresh(start: true, completion: performButtonPressed)
        } else {
            performButtonPressed()
        }
    }
}

// MARK: - loadUI
fileprivate extension BaseButton {
    func loadUI() {
        setupUI()
    }
    
    func loadrefreshControll() {
        if self.activityIndicatorView != nil {
            return
        }
        let view: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            view = UIActivityIndicatorView(style: .medium)
        } else {
            view = UIActivityIndicatorView()
        }
        view.layer.zoom(value: 0.8)
        view.alpha = 0
        addSubview(view)
        view.addConstaits([.centerX:0, .centerY:0, .height:40, .width:40])
        view.layer.cornerRadius = 20
        view.tintColor = self.titleLabel?.textColor
    }
    
    func setupUI() {
        addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        addConstaits([.height:60])
        activityIndicatorView?.addConstaits([.centerX:0, .centerY:0])
    }
    
    //MARK: - updateUI
    private func updateUI() {

        dataUpdated()
    }
    
    private func dataUpdated() {
        if refreshOnPress {
            loadrefreshControll()
        }
    }
}

extension BaseButton {

    func defaultTouches(_ begun:Bool) {
        
    }
    
    private func performTouches(begun:Bool) {
        if let touchAction = touchAction {
            touchAction(begun)
        } else {
            defaultTouches(begun)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        performTouches(begun:true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        performTouches(begun:false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        performTouches(begun:false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        performTouches(begun:false)
    }
}

extension BaseButton {
    private struct ButtonProperties {
        var title:String? = nil
        var image:String? = nil
    }
    static func configure(data:ButtonData?) -> BaseButton {
        let view = BaseButton(frame: .zero)
        view.data = data
        return view
    }
}


