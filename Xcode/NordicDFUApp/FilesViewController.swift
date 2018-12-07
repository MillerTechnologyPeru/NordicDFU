//
//  FilesViewController.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 12/6/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import UIKit

final class FilesViewController: UITableViewController {
    
    // MARK: - Properties
    
    var didSelect: ((FilesViewController, URL) -> ())?
    
    var didCancel: ((FilesViewController) -> ())?
    
    private var files = [URL]() {
        
        didSet { tableView.reloadData() }
    }
    
    private let fileManager = FileManager.default
    
    private lazy var documentsURL: URL = try! self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    private lazy var byteCountFormatter = ByteCountFormatter()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if didCancel != nil {
            
            // set cancel button
            self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel)))
        }
        
        refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: Any? = nil) {
        
        didCancel?(self)
    }
    
    @IBAction func refresh(_ sender: Any? = nil) {
        
        let fileURLs = try! fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants])
        
        self.files = fileURLs
        
        if refreshControl?.isRefreshing ?? false {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    @IBAction func importFile(_ sender: UIBarButtonItem) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.pkware.zip-archive"], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, sender: .barButtonItem(sender))
    }
    
    // MARK: - Methods
    
    private subscript (indexPath: IndexPath) -> URL {
        
        return files[indexPath.row]
    }
    
    private func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        
        let url = self[indexPath]
        
        cell.textLabel?.text = url.lastPathComponent
        
        if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path),
            let size = fileAttributes[.size] as? Int64 {
            
            let sizeText = byteCountFormatter.string(fromByteCount: size)
            
            cell.detailTextLabel?.text = sizeText
            
        } else {
            
            cell.detailTextLabel?.text = ""
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        
        let fileURL = self[indexPath]
        
        if let didSelect = didSelect {
            didSelect(self, fileURL)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (action: UITableViewRowAction, indexPath: IndexPath) in
            
            let fileURL = self[indexPath]
            
            do { try self.fileManager.removeItem(at: fileURL) }
            catch {
                self.showErrorAlert(error.localizedDescription)
                return
            }
            
            self.refresh()
        }
        
        return [deleteAction]
    }
}

// MARK: - UIDocumentPickerDelegate

extension FilesViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        controller.dismiss(animated: true, completion: nil)
        
        for url in urls {
            
            do {
                let newFileURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                try fileManager.copyItem(at: url,
                                          to: newFileURL)
            }
            catch {
                showErrorAlert(error.localizedDescription)
                return
                
            }
        }
        
        refresh()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}
