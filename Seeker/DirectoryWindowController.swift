//
//  DirectoryWindowController.swift
//  Seeker
//
//  Created by John Wells on 3/21/21.
//  Copyright © 2021 John Wells. All rights reserved.
//

import Cocoa
import SwiftUTI

class DirectoryWindowController: NSWindowController {
    typealias DataSource = NSCollectionViewDiffableDataSource<String, FileRep>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, FileRep>
    
    @IBOutlet var infobarAccessoryVC: NSTitlebarAccessoryViewController!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    var dataSource: DataSource?
    
    let layout: NSCollectionViewLayout = {
        NSCollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(96),
                                                  heightDimension: .absolute(72))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(68))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item])
            group.interItemSpacing = .fixed(5)
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(15),
                                                              top: .fixed(15),
                                                              trailing: .fixed(15),
                                                              bottom: .fixed(15))
            
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
    }()
    
    var directoryURL: URL = URL(fileURLWithPath: "/")
    var items: [URL] = []
    
    let folderIcon = NSWorkspace.shared.icon(forFileType: UTI.folder.rawValue)
    let fileIcon = NSWorkspace.shared.icon(forFileType: UTI.data.rawValue)
    
    override var windowNibName: NSNib.Name? {
        String(describing: type(of: self))
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.addTitlebarAccessoryViewController(infobarAccessoryVC)
        
        window?.representedURL = directoryURL
        
        let components = FileManager.default.componentsToDisplay(forPath: directoryURL.path)
        if let count = components?.count, count == 1 {
            window?.title = components?.first ?? "Unknown"
        } else {
            window?.title = components?.last ?? directoryURL.path
        }
        
        do {
            items = try FileManager.default.contentsOfDirectory(at: directoryURL,
                                                                includingPropertiesForKeys: [.isDirectoryKey,
                                                                                             .isApplicationKey],
                                                                options: .skipsHiddenFiles)
            
            let itemCount = items.count
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: directoryURL.path)
            let freeSpace = (attributes[.systemFreeSize] as? NSNumber)?.int64Value
            if let freeSpace = freeSpace {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                let spaceString = formatter.string(fromByteCount: freeSpace)
                
                let itemString = itemCount == 1 ? "item" : "items"
                
                infoLabel.stringValue = "\(itemCount) \(itemString), \(spaceString) available"
            }
        } catch {
            print(error)
        }
        
        collectionView.collectionViewLayout = layout
        collectionView.register(GridIconCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("GridIconItem"))
        collectionView.isSelectable = true
        collectionView.allowsEmptySelection = true
        collectionView.allowsMultipleSelection = true
        
        setupDataSource()
        applySnapshot()
    }
    
    func setupDataSource() {
        dataSource = DataSource(collectionView: collectionView, itemProvider: { (collectionView, indexPath, file) -> NSCollectionViewItem? in
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("GridIconItem"),
                                               for: indexPath) as? GridIconCollectionViewItem
            
            let icon = file.isDirectory ? self.folderIcon : self.fileIcon
            
            
            return item?.configure(for: file, with: icon)
        })
    }
    
    func applySnapshot() {
        var snapshot = Snapshot()
        
        let fileItems: [FileRep] = items.map { item in
            let displayName = FileManager.default.displayName(atPath: item.path)
            let resourceValues = try? item.resourceValues(forKeys: [.isDirectoryKey,
                                                                    .isApplicationKey])
            let isDirectory = resourceValues?.isDirectory ?? false
            let isApplication = resourceValues?.isApplication ?? false
            
            return FileRep(name: displayName,
                           url: item,
                           isDirectory: isDirectory,
                           isApplication: isApplication)
        }.sorted(by: { $0.name < $1.name })
        
        snapshot.appendSections(["Main"])
        snapshot.appendItems(fileItems, toSection: "Main")
        
        dataSource?.apply(snapshot)
    }
    
    @objc func onCollectionViewItemDoubleClick(sender: NSCollectionViewItem) {
        guard let indexPath = collectionView.indexPath(for: sender),
              let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        if item.isDirectory && !item.isApplication {
            let newWindow = DirectoryWindowController()
            newWindow.directoryURL = item.url
            
            newWindow.showWindow(self)
        } else {
            NSWorkspace.shared.open(item.url)
        }
    }
}

struct FileRep: Hashable {
    let id = UUID()
    var name: String
    var url: URL
    var isDirectory: Bool = false
    var isApplication: Bool = false
}
