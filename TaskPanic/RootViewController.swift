//
//  ViewController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 2/27/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit
import SnapKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabBar = MainTabBarController()
        addChildViewController(tabBar)
        view.addSubview(tabBar.view)
        tabBar.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

