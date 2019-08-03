//
//  ActivityIndicatorViewController.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 12/6/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(Android) || os(macOS)
import Android
import AndroidUIKit
#endif

protocol ActivityIndicatorViewController: class {
    
    var view: UIView! { get }
    
    var navigationItem: UINavigationItem { get }
    
    var navigationController: UINavigationController? { get }
    
    func showActivity()
    
    func hideActivity(animated: Bool)
}

extension ActivityIndicatorViewController {
    
    func performActivity <T> (showActivity: Bool = true,
                              _ asyncOperation: @escaping () throws -> T,
                              error errorBlock: ((Self, Error) -> Bool)? = nil,
                              completion: ((Self, T) -> ())? = nil) {
        
        if showActivity { self.showActivity() }
        
        async {
            
            do {
                
                let value = try asyncOperation()
                
                mainQueue { [weak self] in
                    
                    guard let controller = self
                        else { return }
                    
                    if showActivity { controller.hideActivity(animated: true) }
                    
                    // success
                    completion?(controller, value)
                }
            }
                
            catch {
                
                mainQueue { [weak self] in
                    
                    guard let self = self,
                        let controller = self as? (UIViewController & ActivityIndicatorViewController)
                        else { return }
                    
                    if showActivity { controller.hideActivity(animated: false) }
                    
                    // show error
                    
                    log("⚠️ Error: \(error)")
                    
                    let showError = errorBlock?(self, error) ?? true
                    
                    guard showError else { return }
                    
                    if (controller as UIViewController).view.window != nil {
                        
                        controller.showErrorAlert(error.localizedDescription)
                        
                    } else {
                        
                        AppDelegate.shared.window?.rootViewController?.showErrorAlert(error.localizedDescription)
                    }
                }
            }
        }
    }
}
