//
//  LoadingVC.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 19.11.2024.
//

import UIKit

class LoadingVC: SuperVC {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension LoadingVC {
    static func configure() -> LoadingVC? {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: LoadingVC.self)) as? LoadingVC
        return vc
    }
}
