//
//  PresentPopover.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 12/6/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, sender: PopoverPresentingView) {
        
        switch sender {
            
        case let .view(view):
            
            viewController.popoverPresentationController?.sourceRect = view.bounds
            viewController.popoverPresentationController?.sourceView = view
            
        case let .barButtonItem(tabBarItem):
            
            viewController.popoverPresentationController?.barButtonItem = tabBarItem
        }
        
        self.present(viewController, animated: animated, completion: completion)
    }
}

// MARK: - Supporting Types

enum PopoverPresentingView {
    
    case view(UIView)
    case barButtonItem(UIBarButtonItem)
}
