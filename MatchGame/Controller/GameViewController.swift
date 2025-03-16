//
//  ViewController.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 14.11.2024.
//

import UIKit
import SpriteKit

class GameViewController: SuperVC, AudioVCDelegate {
    
    @IBOutlet private weak var shelvesStackView: UIStackView!
    var dragImageView:UIImageView?
    var drView:DragImageView??
    private var viewModel:GameViewModel = .init()
    fileprivate var level:LevelModel.Level = .init(number: 0, difficulty: .easy)
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.audio.removeAll()
        parentVC?.settingsPressedAction = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue(label: "db", qos: .userInitiated).async {
            self.viewModel.initialUserScore = DB.db.profile.score
        }
        viewModel.level = self.level
        createShalveViews()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.removeLoadingView {
                self.audio(.gameBackground1)?.play()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let soundAction = {
            self.parentVC?.soundChanged()
        }
        let quite:()->() = {
            self.presentedViewController?.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
//            self.navigationController?.pushViewController(LevelCompletionVC.configure(.zero, level: .init(number: 1, difficulty: .easy), woneAmount: 5)!, animated: true)
//        })
        parentVC?.settingsPressedAction = {
            self.presentModally(MessageVC.configure(.custom(.init(screenTitle: "Settings", tableData: [
                .init(sectionTitle: "Sound", cells: [
                    .init(title: "Sound", image: "sound", toVC: .sound({
                        soundAction()
                    })),
                    .init(title: "Stop game", toVC: .custom(.init(screenTitle: "Are u sure?", primaryButton: .init(title: "Yes", pressed: {
                        quite()
                    }), tableData: [
                        .init(sectionTitle: "", cells: [
                            .init(title: "s", type: .message(.init(title: "Are you sure?", desription: "All changes sould be lost")))
                        ])
                    ])))
                ])
            ])), screenTitle: "Stop")!)
        }
        parentVC?.updateProgress(0)
    }
    
    var audio:[AudioPlayerManager] = [
        .init(type: .gameBackground.randomElement() ?? .gameBackground1),
        AudioPlayerManager(type: .timeover),
        AudioPlayerManager(type: .coin),
        AudioPlayerManager(type: .error),
        AudioPlayerManager(type: .panStart)
    ]
    
    var dragViews:[DragImageView?] {
        return self.shelvesStackView.arrangedSubviews.compactMap {
            let stack = ($0 as? UIStackView)
            return stack?.arrangedSubviews.compactMap({
                let stack2 = ($0 as? UIStackView)
                return stack2
            }).compactMap({
                $0.arrangedSubviews.compactMap {
                    ($0 as? DragImageView)
                }
            })
        }.flatMap({$0}).flatMap({$0})
    }
    
    var parentVC:HomeVC? {
        navigationController?.parent as? HomeVC
    }

    func checkGameCompletion() {
        if viewModel.gameCompleted {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(LevelCompletionVC.configure(.zero, level: self.level, woneAmount: self.viewModel.droppedCount)!, animated: true)
                    self.navigationController?.viewControllers.forEach({
                        if $0 is Self {
                            $0.removeFromParent()
                            $0.view.removeFromSuperview()
                            
                        }
                    })
                    self.navigationController?.viewControllers.removeAll(where: {$0 is Self})
                    
                }
            }
        }
    }
    
    func buyConfirm(_ item:GameExtraButtonType, _ confirmed:@escaping()->()) {
        let hasMoves = canBuyHammer
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let canBuyResult = !hasMoves ? false : DB.db.profile.canBuy(item.price)
            DispatchQueue.main.async {
                if canBuyResult {
                    self.presentAlert(.init(title: "Are you sure u want to buy \(item.itemDesription.title)", desription: "Price: \(item.price)", image: item.rawValue), screenTitle: "Buy confirmation", okButton: .init(title: "Yes (-\(item.price))", pressed: {
                        self.presentedViewController?.dismiss(animated: true, completion: {
                            DispatchQueue(label: "db", qos: .userInitiated).async {
                                if DB.db.profile.refillBalance(item.price * -1) {
                                    
                                }
                                let new = DB.db.profile.score
                                self.viewModel.initialUserScore = DB.db.profile.score
                                DispatchQueue.main.async {
                                    confirmed()
                                    self.parentVC?.updateBalance(new)
                                }
                            }
                        })
                    }))
                } else {
                    self.presentAlert(.init(title: hasMoves ? "Not enought balance" : "No available moves", desription: hasMoves ? "Play more to get more coins" : "Move some items to to get more moves"), screenTitle: "Error")
                }
                
            }
        }
    }
    
    var canBuyHammer:Bool {
        let types = self.dragViews.filter {
            $0?.dropData.type != LevelModel.DropData.DropType.none
        }
        return types.contains { key in
            types.filter({
                $0?.dropData.type.rawValue == (key?.dropData.type ?? .default).rawValue
            }).count >= 3
        }
    }
    
    func hammerPressed() {
        buyConfirm(.hammer) {
            let types = self.dragViews.filter {
                $0?.dropData.type != LevelModel.DropData.DropType.none
            }
            types.forEach { key in
                let filtered = types.filter({
                    $0?.dropData.type.rawValue == (key?.dropData.type ?? .default).rawValue
                })
                if filtered.count >= 3 {
                    for i in 0..<filtered.count {
                        
                        if i + 1 >= filtered.count,
                           let view = filtered[i]
                        {
                            self.checkHiddenStack(view, isDrop: true)
                            view.dropData.type = .none
                            self.checkHiddenStack(view, isDrop: false)
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    
    func freezeTimerPressed() {
        buyConfirm(.stopTimer, {
            self.viewModel.freezeTimerAmount = 20
        })
    }
    
    func randomizePressed() {
        buyConfirm(.randomize) {
            self.dragViews.filter {
                $0?.dropData.type != LevelModel.DropData.DropType.none
            }.forEach {
                $0?.dropData.type = .randomNormal(self.level)
            }
        }
    }
    
    func paintPressed() {
        buyConfirm(.paint) {
            let new = self.dragViews.filter({
                $0?.dropData.type != LevelModel.DropData.DropType.none
            }).shuffled()
            let pref = Array(new.prefix(new.count / 2))
            let random = new.randomElement()
            pref.forEach {
                $0?.dropData.type = random??.dropData.type ?? .default
            }
        }
    }
    
    func updateMultiplierTimerUI() {
        parentVC?.updateCoinsMultiplier(time: viewModel.lastMovedTimerAmount ?? 0, maxTimer: viewModel.maxLastMovedTime, xValue: viewModel.cointsMultiplier)
    }
    
    func switchCoinsMultiplierTimer(force:Bool = false) {
        if self.viewModel.multiplierTimerStarted && !force {
            self.viewModel.coinsMultiplierInitialTimer()
        } else {
            self.updateMultiplierTimerUI()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                if let time = self.viewModel.lastMovedTimerAmount,
                   time >= 1 {
                    self.viewModel.multiplierTimerStarted = true
                    self.viewModel.lastMovedTimerAmount! -= 1
                    self.switchCoinsMultiplierTimer(force: true)
                } else {
                    self.viewModel.cointsMultiplier = 1
                    self.viewModel.multiplierTimerStarted = false
                    self.viewModel.multiplierTimerStarted = false
                    self.viewModel.lastMovedTimerAmount = nil
                }
            })
        }
    }
    
    @IBAction private func closePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

fileprivate extension GameViewController {
    
    func rowStack(_ rowSection:Int,
                  _ itemsInRow:Int, hidden:Bool = false, types:[GameViewModel.DropData.DropType]
    ) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = shelvesStackView.spacing / 2
        stack.tag = rowSection
        stack.distribution = shelvesStackView.distribution
        stack.alpha = hidden ? 0.2 - CGFloat(rowSection / 10) : 1
        var types = types
        if types.isEquel {
            types = [GameViewModel.DropData.DropType.allCases.first ?? .default,
                     GameViewModel.DropData.DropType.allCases.last ?? .default,
                     GameViewModel.DropData.DropType.allCases.first ?? .default]
        }
        types.forEach {
            addView(data: .init(type: $0), to: stack, hinnden: hidden)
        }
        return stack
    }
    
    func createShalveViews() {
        viewModel.droppedCount = 0
        let data = viewModel.shavedData
        let types = viewModel.shaves
        shelvesStackView.backgroundColor = .primaryBackground.withAlphaComponent(0.2)
        shelvesStackView.layer.cornerRadius = 5
        //        shelvesStackView.layer.borderColor = UIColor.darkContainer.cgColor
        //        shelvesStackView.layer.borderWidth = 3
        for section in 0..<data.numSections {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = 20
            horizontalStackView.tag = section
            horizontalStackView.distribution = shelvesStackView.distribution
            
            
            for rowSection in 0..<data.rowSections {
                let sectionFrom = (data.numRows * section) + (data.itemsInRow * rowSection)
                var typesSection:[GameViewModel.DropData.DropType] = []
                for i in 0..<data.itemsInRow {
                    typesSection.append(types[sectionFrom + i])
                }
                
                let stack = rowStack(rowSection, data.itemsInRow, types:typesSection)
                stack.layer.name = "primary"
                let shevasImage = UIImageView(image: ._3Shaves)
                shevasImage.contentMode = .scaleToFill
                stack.insertSubview(shevasImage, at: 0)
                shevasImage.addConstaits([.left:-10, .width:CGFloat(data.itemsInRow) * viewModel.itemSize + 20, .height:viewModel.itemSize / 3, .bottom:0])
                for _ in 0..<data.hiddenShaves {
                    let changeAt = Int.random(in: 1..<data.itemsInRow)
                    var types = (0..<data.itemsInRow).compactMap({ _ in
                        types.randomElement() ?? .default
                    })
                    let difficultyOk = self.level.difficulty != .hard || ((horizontalStackView.tag) % 2 == 0)
                    if difficultyOk,
                       let first = types.first,
                       first != types[changeAt] {
                        types.remove(at: changeAt)
                        types.insert(first, at: changeAt)
                    }
                    
                    let hidden = rowStack(rowSection, data.itemsInRow, hidden: true, types: types)
                    hidden.alpha = 0.1
                    hidden.isUserInteractionEnabled = false
                    stack.insertSubview(hidden, at: 0)
                    hidden.addConstaits([.left:0, .right:0, .top:-10, .bottom:10])
                    
                }
                horizontalStackView.addArrangedSubview(stack)
            }
            
            shelvesStackView.addArrangedSubview(horizontalStackView)
            
        }
        self.viewModel.timerValue = CGFloat(self.viewModel.initialTimerValue)
        self.startTimer()
    }
    
    func startTimer() {
        if viewModel.freezeTimerAmount >= 1 {
            viewModel.freezeTimerAmount -= 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.startTimer()
            })
        } else {
            parentVC?.updateTimer(Int(viewModel.timerValue))
            if viewModel.timerValue <= 6 {
                self.audio(.timeover)?.play()
            }
            
            if self.audio.isEmpty {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.viewModel.timerValue -= 1
                if self.viewModel.timerValue >= 0 {
                    if self.isBeingDismissed {
                        return
                    }
                    self.startTimer()
                } else {
                    self.timeOver()
                }
            })
        }
    }
    
    private func dropAnimation(to view:UIView, completion:@escaping()->()) {
        viewModel.droppedCount += (1 * viewModel.cointsMultiplier)
        parentVC?.updateBalance(viewModel.initialUserScore + viewModel.droppedCount)
        
        self.audio(.coin)?.play()
        var image:UIImage = .star
        if #available(iOS 13.0, *) {
            image = image.withTintColor(.yellow)
        }
        let star = UIImageView(image: image)
        star.tintColor = .yellow
        star.frame = .init(origin: view.convert(view.bounds.origin, to: self.view), size: .init(width: 15, height: 15))
        self.view.addSubview(star)
        UIView.animate(withDuration: 2.4) {
            var frame = self.parentVC?.balanceLabel?.convert(self.parentVC?.balanceLabel.bounds ?? .zero, to: self.view) ?? .zero
            frame.origin = .init(x: frame.minX, y: -50)
            star.frame = frame
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                star.layer.zoom(value: 1.3)
                star.alpha = 0
            } completion: { _ in
                star.removeFromSuperview()
            }
            
        }
        
        let subView = UIView(frame: .init(origin: .zero, size: .init(width: viewModel.itemSize, height: self.view.frame.height / 1.2)))
        view.addSubview(subView)
        let skView = SKView(frame: subView.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.backgroundColor = .clear
        subView.addSubview(skView)
        
        let scene = DropNodeScene(size: skView.bounds.size)
        scene.dropped = {
            subView.removeWithAnimation {
                view.layer.zPosition = 1
                completion()
            }
        }
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    func checkLayerMatches() {
        var hasMoves = false
        let openedAll = shelvesStackView.arrangedSubviews.compactMap {
            if let horizontal = $0 as? UIStackView {
                let array = horizontal.arrangedSubviews.compactMap {
                    return ($0 as? UIStackView)?.subviews.contains(where: {
                        $0.isUserInteractionEnabled == false && !(($0 as? UIStackView)?.arrangedSubviews.isEmpty ?? true)
                    })
                }
                
                return !array.contains(true)
            } else {
                return true
            }
        }
        let types = self.dragViews.compactMap {
            ($0?.dropData)?.type
        }
        
        var typeCounts:[LevelModel.DropData.DropType:Int] = [:]
        LevelModel.DropData.DropType.allCases.forEach { type in
            if type != .none {
                let count = types.filter({
                    $0.rawValue == type.rawValue
                }).count
                typeCounts.updateValue(count, forKey: type)
                if count >= 3 {
                    hasMoves = true
                }
            }
        }
        types.forEach({
            print($0.rawValue)
        })
        if !hasMoves {
            viewModel.hasMoves = false
        } else {
            viewModel.hasMoves = true
        }
        viewModel.openedAll = !openedAll.contains(false)
        viewModel.droppedCount = viewModel.droppedCount
        checkGameCompletion()
    }
    
    private func checkHiddenStack(_ view:UIView, isDrop:Bool = false) {
        let stack = self.stack(subview: view)
        let types = stack?.arrangedSubviews.compactMap({
            ($0 as? DragImageView)?.dropData.type
        })
        
        if types.isEquel {
            if isDrop {
                self.viewModel.coinsMultiplierInitialTimer()
                self.switchCoinsMultiplierTimer()
            }
            var foundHidden = false
            if let hiddenStack = stack?.subviews.first as? UIStackView
            {
                if !hiddenStack.arrangedSubviews.isEmpty  {
                    foundHidden = true
                    stack?.arrangedSubviews.forEach({
                        if let view = $0 as? DragImageView,
                           hiddenStack.arrangedSubviews.count
                            >= stack?.arrangedSubviews.count ?? 1
                        {
                            view.dropData = (hiddenStack.arrangedSubviews[view.tag] as? DragImageView)!.dropData
                            self.setGestureInteraction(view)
                            view.animateImage(like: true)
                            if isDrop {
                                dropAnimation(to: view) {
                                    
                                }
                            }
                        }
                    })
                }
                
                hiddenStack.removeWithAnimation {
                    if isDrop {
                        self.checkLayerMatches()
                    }
                }
            }
            AudioBoxService().vibrate()
            if !foundHidden {
                stack?.arrangedSubviews.forEach({
                    if let view = $0 as? DragImageView {
                        view.dropData = .init(type:.none)
                        self.setGestureInteraction(view)
                    }
                })
                if isDrop {
                    dropAnimation(to: view) {
                    }
                }
            }
        }
        else {
            checkLayerMatches()
        }
        setGestureInteraction(view as! DragImageView)
        if isDrop {
            checkLayerMatches()
        }
    }
    
    func timeOver() {
        if !viewModel.gameCompleted {
            viewModel.gameLost = true
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(LevelCompletionVC.configure(self.parentVC?.balanceLabel.convert(self.parentVC?.balanceLabel.bounds.origin ?? .zero, to: self.view) ?? .zero, level: self.level, woneAmount: 0)!, animated: true)
                self.navigationController?.viewControllers.forEach({
                    if $0 is Self {
                        $0.removeFromParent()
                        $0.view.removeFromSuperview()
                        
                    }
                })
                self.navigationController?.viewControllers.removeAll(where: {$0 is Self})
            }
        }
    }
    
    func addView(data:LevelModel.DropData, to stack:UIStackView, hinnden:Bool) {
        let newView = DragImageView(dropData: data)
        newView.tag = stack.arrangedSubviews.count
        newView.layer.cornerRadius = 6
        stack.addArrangedSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.widthAnchor.constraint(equalToConstant: viewModel.itemSize).isActive = true
        newView.heightAnchor.constraint(equalToConstant: viewModel.itemSize * viewModel.heightMultiplier).isActive = true
        newView.contentMode = .scaleAspectFit
        newView.isUserInteractionEnabled = true
        setGestureInteraction(newView)
    }
    
    func setGestureInteraction(_ view:DragImageView) {
        view.isUserInteractionEnabled = true
        checkGameCompletion()
        let all = viewModel.allDataCount
        let progress = Float(viewModel.droppedCount) / Float(all)
        parentVC?.updateProgress(CGFloat(progress))
    }
    
    private func stack(subview:UIView) -> UIStackView? {
        if let stack = subview.superview as? UIStackView {
            return stack
        }
        return nil
    }
    
    func setDraggingPreviewFrame(_ touches: Set<UITouch>) {
        let frame = touches.first?.location(in: self.view) ?? .zero
        dragImageView?.frame.origin = .init(x: frame.x - (viewModel.itemSize / 2), y: frame.y - (viewModel.itemSize * 1.5))
    }
    
    func touchesEnded() {
        dragViews.forEach {
            $0?.layer.borderWidth = 0
            $0?.backgroundColor = .clear
        }
        drView??.alpha = 1
        drView = nil
        dragImageView?.removeWithAnimation(complation: {
            self.dragImageView = nil
        })
    }
}

extension GameViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        drView = dragViews.filter({
            $0?.dropData.type != LevelModel.DropData.DropType.none
        }).first {
            $0?.contains(touches, inView: self.view) ?? false
        }
        drView??.backgroundColor = .clear
        dragImageView = .init(image: drView??.toImage())
        dragImageView?.frame = .init(origin: .zero, size: .init(width: viewModel.itemSize, height: viewModel.itemSize * viewModel.heightMultiplier))
        self.view.addSubview(dragImageView!)
        setDraggingPreviewFrame(touches)
        UIView.animate(withDuration: 0.2) {
            self.drView??.alpha = 0
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if drView != nil {
            dragViews.filter({
                $0?.dropData.type == LevelModel.DropData.DropType.none
            }).forEach {
                if $0?.contains(touches, inView: self.view) ?? false {
                    $0?.layer.borderColor = UIColor.container.cgColor
                    $0?.layer.borderWidth = 2
                } else {
                    $0?.layer.borderWidth = 0
                }
            }
            setDraggingPreviewFrame(touches)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesEnded()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let newDestinationView = dragViews.filter({
            $0?.dropData.type == LevelModel.DropData.DropType.none
        }).first {
            $0?.contains(touches, inView: self.view) ?? false
        }
        let dragHolderView = self.drView
        if let newDestinationView,
           let drView, let drView,
           let newDestinationView,
           drView.dropData.type != .none {
            newDestinationView.dropData.type = drView.dropData.type
            drView.dropData.type = .none
        }
        touchesEnded()
        guard let newDestinationView, let newDestinationView else {
            return
        }
        setGestureInteraction(newDestinationView)
        
        checkHiddenStack(newDestinationView, isDrop: true)
        guard let dragHolderView, let dragHolderView else {
            return
        }
        checkHiddenStack(dragHolderView)
    }
}

extension GameViewController {
    static func configure(_ lvl: LevelModel.Level) -> GameViewController? {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: GameViewController.self)) as? GameViewController
        vc?.level = lvl
        vc?.addLoadingView()
        return vc
    }
}

