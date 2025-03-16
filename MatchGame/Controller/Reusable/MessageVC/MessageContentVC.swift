//
//  MessageContentVC.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 21.11.2024.
//

import UIKit

class MessageContentVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    var screenData: MessageVC.ScreenData = .init(screenTitle: "", tableData: [])
    var parentVC:MessageVC? {
        (parent as? UINavigationController)?.parent as? MessageVC
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = screenData.screenTitle
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}
extension MessageContentVC {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return screenData.tableData.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenData.tableData[section].cells.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = screenData.tableData[indexPath.section].cells[indexPath.row]
        switch data.type {
        case .message(let message):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MessageConfirmationCell.self ), for: indexPath) as! MessageConfirmationCell
            cell.set(title: message.title, description: message.desription)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MessageCollectionCell.self ), for: indexPath) as! MessageCollectionCell
            let float = data.type?.floatData
            cell.sliderDefaultValue = CGFloat(float?.defaultValue ?? 0)
            cell.set(title: data.title, imageName: data.image, isOn: float == nil ? nil : ((float?.progress ?? 0) >= 1), isOnChanged: {
                float?.didChanged($0 ? (float?.defaultValue ?? 1) : 0)
            }, progressValue: float?.progress, progressChanged: {
                float?.didChanged(Int($0))
            })
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = screenData.tableData[indexPath.section].cells[indexPath.row]
        if let data = data.toVC {
            //click here
            parentVC?.homeVC?.audio(.menu)?.play()
            self.navigationController?.pushViewController(MessageContentVC.configure(screenData: data.screenData(db: DB.db, okPressed: {
                self.parentVC?.okPress()
            }))!, animated: true)
        }
    }
}



extension MessageContentVC {
    static func configure(screenData: MessageVC.ScreenData) -> MessageContentVC? {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: MessageContentVC.self)) as? MessageContentVC
        vc?.screenData = screenData
        return vc
    }
}
