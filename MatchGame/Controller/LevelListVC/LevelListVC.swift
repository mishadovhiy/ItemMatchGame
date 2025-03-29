//
//  LevelListVC.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import UIKit

class LevelListVC: SuperVC, AudioVCDelegate {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var backgroundMusic = AudioPlayerManager(type: .lvlBackground.randomElement() ?? .lvlBackground1)
        var lvlSelectedMusic:AudioPlayerManager? {
            parentVC?.audio.first(where: {$0.type == .lvlSelected})
}
    var audio: [AudioPlayerManager] = []
    var allAudion:[AudioPlayerManager] {
        var results = audio
        results.append(contentsOf: [backgroundMusic, lvlSelectedMusic ?? .init(type: .bonus)])
        return results
    }

    private var user:DB.DataBase.Profile? = nil {
        didSet {
            if !Thread.isMainThread {
                DispatchQueue.main.async {
                    self.parentVC?.updateBalance(self.user?.score ?? 0)
                }
            } else {
                self.parentVC?.updateBalance(self.user?.score ?? 0)
            }
        }
    }
    
    var parentVC:HomeVC? {
        navigationController?.parent as? HomeVC
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parentVC?.updateCoinsMultiplier(time: 0, maxTimer: 0, xValue: 0)
        backgroundMusic.play()
        UIView.animate(withDuration: 0.3) {
            self.parentVC?.primaryButton.isHidden = false
        } completion: { _ in
            self.dbUpdated()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.allAudion.forEach {
            $0.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbUpdated()
        loadUI()
//        collectionView.isPagingEnabled = true
    }
    
    private func dbUpdated(updateParentScore:Bool = false) {
        self.backgroundMusic.play()
        DispatchQueue(label: "db", qos: .userInitiated).async {
            self.user = DB.db.profile
            let last = self.user?.levels.sorted(by: {$0.key > $1.key})
            let lastKey = last?.first?.key ?? 0
            DispatchQueue.main.async {
                if updateParentScore {
                    self.parentVC?.updateBalance(self.user?.score ?? 0)
                }
                var selectedSetted = false
                selectedSetted = true
                self.parentVC?.lastUnlockedLevel = .init(number: lastKey + 3, difficulty: .easy)
                self.parentVC?.selectedLevel = .init(number: lastKey, difficulty: .easy)
                print(self.user?.score, " ythrgerfsd")
                self.collectionView.reloadData()
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                if selectedSetted {
                    self.collectionView.scrollToItem(at: .init(row: (self.parentVC?.selectedLevel.number ?? 0) - 1, section: 1), at: .centeredHorizontally, animated: true)
                    self.collectionView.subviews.first(where: {$0 is UIImageView})?.frame.size = self.collectionView.contentSize
                } else {
                    self.collectionView.subviews.first(where: {$0 is UIImageView})?.frame.size = self.collectionView.contentSize

                }
            }
        }
    }
    
    override func soundChanged() {
        self.allAudion.forEach {
            $0.updateValuem()
        }
        super.soundChanged()
    }
}

extension LevelListVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.size.width / (indexPath.section == 0 ? 0.5 : 2), height: view.frame.size.height / (indexPath.section == 0 ? 3 : 3))
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         switch section {
        case 0:return 1
        case 1:
             var score = self.parentVC?.lastUnlockedLevel.number ?? 0
            if score <= LevelModel.minimumUnlockedLvl.rawValue {
                score = LevelModel.minimumUnlockedLvl.rawValue
            }
            return score + 2
         case 2:
             return 1
         default:
             return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 || indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: LevelCollectionCell.self), for: indexPath) as! LevelCollectionCell
            cell.set(indexPath.row + 1, selected: self.parentVC?.selectedLevel ?? .init(number: 0, difficulty: .easy), user: indexPath.section == 2 ? [] : self.user?.levels[indexPath.row + 1] ?? [], userLastLevel: DB.db.profile.score, isLocked: indexPath.section == 2, pressed: { difficulty, lvl in
                if indexPath.section != 2 {
                    self.parentVC?.selectedLevel = .init(number: lvl, difficulty: difficulty)
                    collectionView.reloadData()
                }
            })
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: LevelHeadCollectionCell.self), for: indexPath) as! LevelHeadCollectionCell
            return cell
        }
    }
}


fileprivate extension LevelListVC {
    func loadUI() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 30
        layout.minimumLineSpacing = 120
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        let stack = UIStackView()
        stack.axis = .horizontal
        let stackCount = (LevelModel.levelCount.rawValue / 10) + 1
        for _ in 0..<stackCount {
            loadBackground(to: stack)
        }
        collectionView.insertSubview(stack, at: 0)
        stack.isUserInteractionEnabled = false
        stack.layer.zPosition = -100
        let firstView = (stack.arrangedSubviews.last as? UIImageView)?.image?.size.width ?? 0
        stack.addConstaits([.left:-400, .top:-120, .bottom:0, .width:firstView * CGFloat(stackCount)])
    }
    
    func loadBackground(to:UIStackView, insert:Int? = nil) {
        let image:UIImage = !to.arrangedSubviews.isEmpty ? .levelBackground2 : .menuBackground1
        let background = UIImageView(image: image.resizableImage(withCapInsets: .init(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))
        if let insert {
            to.insertArrangedSubview(background, at: insert)
        } else {
            to.addArrangedSubview(background)
        }
        background.layer.zPosition = -100
        background.contentMode = .scaleAspectFit
    }

}

extension LevelListVC {
    static func configure() -> LevelListVC? {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: LevelListVC.self)) as? LevelListVC
    }
}
