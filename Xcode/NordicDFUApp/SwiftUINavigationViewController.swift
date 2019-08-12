//
//  SwiftUINavigationViewController.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 8/9/19.
//  Copyright © 2019 PureSwift. All rights reserved.
//

import Foundation
import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

class SwiftUINavigationViewController: UINavigationController { }

@objc(SettingsNavigationViewController)
final class SettingsNavigationViewController: SwiftUINavigationViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if #available(iOS 13, *) {
            let rootViewController = UIHostingController(rootView: SettingsView())
            self.viewControllers = [rootViewController]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
