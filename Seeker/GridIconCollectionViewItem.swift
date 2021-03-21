//
//  GridIconCollectionViewItem.swift
//  Seeker
//
//  Created by John Wells on 3/21/21.
//  Copyright © 2021 John Wells. All rights reserved.
//

import Cocoa

class GridIconCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func onDoubleClick(_ sender: Any) {
        NSApp.sendAction(#selector(DirectoryWindowController.onCollectionViewItemDoubleClick(sender:)), to: nil, from: self)
    }
    
}

extension GridIconCollectionViewItem {
    func configure(for rep: FileRep, with icon: NSImage) -> Self {
        iconView?.image = icon
        label.stringValue = rep.name
        
        return self
    }
}
