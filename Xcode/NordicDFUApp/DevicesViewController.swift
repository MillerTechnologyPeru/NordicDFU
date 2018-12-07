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
    
    private static let filterDefaultsKey = "DevicesFilter"
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    
    private var devices = [Device]() {
        didSet { tableView.reloadData() }
    }
    
    private var filter: String = "" {
        
        didSet {
            UserDefaults.standard.set(filter, forKey: DevicesViewController.filterDefaultsKey)
            guard UserDefaults.standard.synchronize()
                else { assertionFailure("Could not save user defaults"); return }
        }
    }
    
    // MARK: - Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load filter string
        if let filter = UserDefaults.standard.string(forKey: DevicesViewController.filterDefaultsKey), filter.isEmpty == false {
            
            scan(filter: filter)
        }
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
            try DeviceManager.shared.scan(duration: 5, filterPeripherals: filterPeripherals) { (device) in
                mainQueue { [weak self] in self?.foundDevice(device) }
            }
        }, completion: { (viewController, _) in
            viewController.refreshControl?.endRefreshing()
        })
    }
    
    // MARK: - Methods
    
    private func scan(filter: String) {
        
        self.filter = filter
        if self.searchBar.text != filter {
            self.searchBar.text = filter
        }
        self.scan()
    }
    
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
    
    private func uploadFirmware(at url: URL, for device: Device) {
        
        performActivity({
            let zip = try DFUStreamZip(url: url)
            let start = Date()
            try DeviceManager.shared.uploadFirmware(zip.firmware, for: device.scanData.peripheral, timeout: 30) {
                switch $0 {
                case let .write(type, offset: offset, total: total):
                     let percentage = (Float(offset) / Float(total)) * 100
                     log("Wrote \(offset) bytes for \(type) object (\(String(format: "%.2f", percentage))%)")
                case let .verify(type, offset: offset, checksum: checksum):
                    log("Verified \(offset) bytes for \(type) object (\(String(checksum, radix: 16)))")
                case let .execute(type, index: index, total: total):
                    log("Executed \(type) object \(index + 1)/\(total)")
                }
            }
            let duration = Date().timeIntervalSince(start)
            log("Successfully uploaded firmware (\(String(format: "%.2f", duration))s)")
        })
    }
    
    private func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        
        let device = self[indexPath]
        
        cell.textLabel?.text = device.scanData.advertisementData.localName ?? device.scanData.peripheral.description
        
        cell.detailTextLabel?.text = """
        Type: \(device.type)
        Mode: \(device.mode)
        """
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
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        
        let device = self[indexPath]
        
        switch device.mode {
            
        case .enterBootloader:
            
            // enter bootloader mode
            performActivity({
                try DeviceManager.shared.enterBootloader(for: device.scanData.peripheral)
            }, completion: { (viewController, _) in
                viewController.scan(filter: "Dfu")
            })
            
        case .uploadFirmware:
            
            // select file to upload
            let filesViewController = self.storyboard!.instantiateViewController(withIdentifier: "FilesViewController") as! FilesViewController
            
            filesViewController.didCancel = {
                $0.dismiss(animated: true, completion: nil)
            }
            filesViewController.didSelect = { [unowned self] in
                $0.dismiss(animated: true, completion: nil)
                self.uploadFirmware(at: $1, for: device)
            }
            
            present(UINavigationController(rootViewController: filesViewController), animated: true, completion: nil)
        }
    }
}

// MARK: - UISearchBarDelegate

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
