//
//  DataSourceStructure.swift
//  Folk
//
//  Created by Rocco Del Priore on 11/25/17.
//  Copyright © 2017 particle. All rights reserved.
//

import Foundation
import UIKit

open class DataSourceItem {
    open var type = -1
    open var title = ""
    open var subtitle = ""
    open var image: UIImage?
    open var imageURL: URL?
    open var selectedImage: UIImage?
    open var selectedImageURL: URL?
    open var attributedTitle: NSAttributedString?
    open var tableViewCellAccessoryType = UITableViewCellAccessoryType.none
    
    public init() {
        
    }
    public func sectionForObject() -> DataSourceSection {
        return DataSourceSection(items: [self])
    }
    public func sectionForObjectWithHeaderHeight(height: CGFloat) -> DataSourceSection {
        let section = DataSourceSection(items: [self])
        section.headerHeight = height
        return section
    }
    public func sectionForObjectWithHeaderAndFooterHeight(headerHeight: CGFloat, footerHeight: CGFloat) -> DataSourceSection {
        let section = DataSourceSection(items: [self])
        section.headerHeight = headerHeight
        section.footerHeight = footerHeight
        return section
    }
}

open class DataSourceSection {
    open var items = [DataSourceItem]()
    open var headerHeight: CGFloat = 0.0
    public var headerTitle = ""
    open var footerHeight: CGFloat = 0.0
    open var footerTitle = ""
    
    public init(items: [DataSourceItem]) {
        self.items = items
    }
}

open class DataSource {
    open var title = ""
    open var sections = [DataSourceSection]()
    open var cellTypes = [Int]()
    open var reloader: DataSourceReloader?
    
    required public init() {
        
    }
    
    class open func itemWith(cellType: Int, title: String, image: UIImage?, subtitle: String?) -> DataSourceItem {
        let item = DataSourceItem()
        item.type = cellType
        item.title = title
        item.image = image
        
        if let itemSubtitle = subtitle {
            item.subtitle = itemSubtitle
        }
        return item
    }
    open func numberOfSections() -> Int {
        return sections.count
    }
    open func numberOfItemsInSection(section: Int) -> Int {
        return sections[section].items.count
    }
    open func cellTypeForIndexPath(indexPath: IndexPath) -> Int {
        return modelObjectForIndexPath(indexPath: indexPath).type
    }
    open func modelObjectForIndexPath(indexPath: IndexPath) -> DataSourceItem {
        return sections[indexPath.section].items[indexPath.row]
    }
    open func heightForHeaderInSection(section: Int) -> CGFloat {
        return sections[section].headerHeight
    }
    open func heightForFooterInSection(section: Int) -> CGFloat {
        return sections[section].footerHeight
    }
    open func headerTitleForSection(section: Int) -> String {
        return sections[section].headerTitle
    }
    open func footerTitleForSection(section: Int) -> String {
        return sections[section].footerTitle
    }
    open func selectItemAtIndexPath(indexPath: IndexPath) {
        
    }
    open func cellClassForType(type: Int) -> AnyClass {
        return DataSourceTableViewCell.self
    }
}

@objc public protocol DataSourceReloader {
    @objc func reloadData()
    @objc optional func reloadDataAtIndexPath(indexPath: IndexPath)
    @objc optional func reloadDataAtIndexPaths(indexPaths: [IndexPath])
    @objc optional func insertRowsAtIndexPaths(indexPaths: [IndexPath])
    @objc optional func removeRowsAtIndexPaths(indexPaths: [IndexPath])
    @objc optional func reloadSections(sections: IndexSet)
    @objc optional func insertSections(sections: IndexSet)
    @objc optional func removeSections(sections: IndexSet)
}
