//
//  WindowContentViewController.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2016-06-05.
//
//  ---------------------------------------------------------------------------
//
//  © 2016-2023 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit

final class WindowContentViewController: NSSplitViewController {
    
    // MARK: Public  Properties
    
    private(set) lazy var documentViewController = DocumentViewController()
    
    
    // MARK: Private Properties
    
    private weak var inspectorViewItem: NSSplitViewItem?
    
    
    
    // MARK: -
    // MARK: Split View Controller Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // -> Need to set *both* identifier and autosaveName to make autosaving work.
        self.splitView.identifier = NSUserInterfaceItemIdentifier("windowContentSplitView")
        self.splitView.autosaveName = "windowContentSplitView"
        
        self.addChild(self.documentViewController)
        
        let storyboard = NSStoryboard(name: "Inspector", bundle: nil)
        let inspectorViewController: NSViewController = storyboard.instantiateInitialController()!
        let inspectorViewItem: NSSplitViewItem
        if #available(macOS 14, *) {
            inspectorViewItem = NSSplitViewItem(inspectorWithViewController: inspectorViewController)
            inspectorViewItem.minimumThickness = NSSplitViewItem.unspecifiedDimension
            inspectorViewItem.maximumThickness = NSSplitViewItem.unspecifiedDimension
        } else {
            inspectorViewItem = NSSplitViewItem(viewController: inspectorViewController)
            inspectorViewItem.holdingPriority = .init(261)
            inspectorViewItem.canCollapse = true
        }
        inspectorViewItem.isCollapsed = true
        self.addSplitViewItem(inspectorViewItem)
        self.inspectorViewItem = inspectorViewItem
    }
    
    
    override func validateUserInterfaceItem(_ item: any NSValidatedUserInterfaceItem) -> Bool {
        
        switch item.action {
            case #selector(toggleInspector):
                (item as? NSMenuItem)?.title = self.isInspectorShown
                    ? String(localized: "Hide Inspector")
                    : String(localized: "Show Inspector")
                
            case #selector(getInfo):
                (item as? NSMenuItem)?.state = self.isInspectorShown(pane: .document) ? .on : .off
                
            case #selector(toggleOutlineMenu):
                (item as? NSMenuItem)?.state = self.isInspectorShown(pane: .outline) ? .on : .off
                
            case #selector(toggleWarningsPane):
                (item as? NSMenuItem)?.state = self.isInspectorShown(pane: .warnings) ? .on : .off
                
            default: break
        }
        
        return super.validateUserInterfaceItem(item)
    }
    
    
    
    // MARK: Public Methods
    
    /// Open the desired inspector pane.
    ///
    /// - Parameter pane: The inspector pane to open.
    func showInspector(pane: InspectorPane) {
        
        self.setInspectorShown(true, pane: pane)
    }
    
    
    
    // MARK: Action Messages
    
    /// Toggle visibility of the inspector.
    @IBAction override func toggleInspector(_ sender: Any?) {
        
        if #available(macOS 14, *) {
            super.toggleInspector(sender)
        } else {
            self.inspectorViewItem?.animator().isCollapsed.toggle()
        }
    }
    
    
    /// Toggle visibility of the document inspector pane.
    @IBAction func getInfo(_ sender: Any?) {
        
        self.toggleVisibilityOfInspector(pane: .document)
    }
    
    
    /// Toggle visibility of the outline pane.
    @IBAction func toggleOutlineMenu(_ sender: Any?) {
        
        self.toggleVisibilityOfInspector(pane: .outline)
    }
    
    
    /// Toggle visibility of warnings pane.
    @IBAction func toggleWarningsPane(_ sender: Any?) {
        
        self.toggleVisibilityOfInspector(pane: .warnings)
    }
    
    
    
    // MARK: Private Methods
    
    /// The view controller for the inspector.
    private var inspectorViewController: InspectorViewController? {
        
        self.inspectorViewItem?.viewController as? InspectorViewController
    }
    
    
    /// Whether the inspector is opened.
    private var isInspectorShown: Bool {
        
        self.inspectorViewItem?.isCollapsed == false
    }
    
    
    /// Set the visibility of the inspector and switch pane with animation.
    private func setInspectorShown(_ shown: Bool, pane: InspectorPane) {
        
        self.inspectorViewItem!.animator().isCollapsed = !shown
        self.inspectorViewController!.selectedTabViewItemIndex = pane.rawValue
    }
    
    
    /// whether the given pane in the inspector is currently shown
    private func isInspectorShown(pane: InspectorPane) -> Bool {
        
        self.isInspectorShown && (self.inspectorViewController?.selectedPane == pane)
    }
    
    
    /// toggle visibility of pane in the inspector
    private func toggleVisibilityOfInspector(pane: InspectorPane) {
        
        self.setInspectorShown(!self.isInspectorShown(pane: pane), pane: pane)
    }
}
