//
//  ViewController.swift
//  ScrollableCompose
//
//  Created by ASHIS LAHA on 3/23/25.
//

import UIKit

class ViewController: UIViewController {

    let dynamicContentVC = DynamicContentViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Add the child view controller to the parent
        addChild(dynamicContentVC)
        
        // 2. Set the child's view frame or constraints
        dynamicContentVC.view.frame = view.bounds
        view.addSubview(dynamicContentVC.view)
        
        // 3. Notify the child that it has moved to the parent
        dynamicContentVC.didMove(toParent: self)
    }
}

