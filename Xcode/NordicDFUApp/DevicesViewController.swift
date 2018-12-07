//
//  DevicesViewController.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 12/6/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import Bluetooth
import GATT
import NordicDFU

#if os(iOS)
import UIKit
#endif

final class DevicesViewController: UITableViewController {
    
    typealias Device = NordicPeripheral<NativeCentral.Peripheral, NativeCentral.Advertisement>
    
    // MARK: - Properties
    
    private var devices = [Device]() {
        didSet { tableView.reloadData() }
    }
    
    private var filter = ""
    
    // MARK: - Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    // MARK: - Actions
    
    @IBAction func scan() {
        
        typealias ScanResult = ScanData<NativeCentral.Peripheral, NativeCentral.Advertisement>
        
        devices.removeAll()
        
        let filter = self.filter
        
        let filterPeripherals: ([ScanResult]) -> ([ScanResult]) = {
            $0.filter { ($0.advertisementData.localName ?? "").localizedCaseInsensitiveContains(filter) }
        }
        
        performActivity({
            try DeviceManager.shared.scan(duration: 10, filterPeripherals: filterPeripherals) { (device) in
                mainQueue { [weak self] in self?.foundDevice(device) }
            }
        }, completion: { (viewController, value) in
            viewController.refreshControl?.endRefreshing()
        })
    }
    
    // MARK: - Methods
    
    private subscript (indexPath: IndexPath) -> Device {
        
        return devices[indexPath.row]
    }
    
    private func foundDevice(_ device: Device) {
        
        assert(Thread.isMainThread)
        
        var devices = self.devices
        devices = devices.filter { $0.scanData.peripheral != device.scanData.peripheral }
        devices.append(device)
        devices.sort(by: { $0.scanData.rssi < $1.scanData.rssi })
        self.devices = devices
    }
    
    private func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        
        let device = self[indexPath]
        
        cell.textLabel?.text = device.scanData.advertisementData.localName ?? device.scanData.peripheral.description
        cell.detailTextLabel?.text = "Type: \(device.type)\nMode:\(device.mode)"
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
}

extension DevicesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        scan()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.filter = searchText
    }
}

// MARK: - ActivityIndicatorViewController

extension DevicesViewController: ActivityIndicatorViewController {
    
    func showActivity() {
        
        
    }
    
    func hideActivity(animated: Bool) {
        
        
    }
}
