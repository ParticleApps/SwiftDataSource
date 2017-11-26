//
//  DataSourceTableView.swift
//  SwiftDataSource
//
//  Created by Rocco Del Priore on 11/25/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import Foundation
import UIKit

open class DataSourceTableViewCell: UITableViewCell {
    open func configureWithModel(model: DataSourceItem) {
        if let attributedTitle = model.attributedTitle {
            textLabel?.attributedText = attributedTitle
            textLabel?.numberOfLines = 0
            textLabel?.lineBreakMode = .byWordWrapping
        }
        else {
            textLabel?.text = model.title
        }
        
        detailTextLabel?.text = model.subtitle
        imageView?.image = model.image
        accessoryType = model.tableViewCellAccessoryType
    }
}

open class DataSourceTableView: UITableView, UITableViewDataSource, UITableViewDelegate, DataSourceReloader {
    open let dataSourceModel: DataSource
    
    //MARK: Initializers
    public init(dataSourceModel: DataSource, frame: CGRect, style: UITableViewStyle) {
        self.dataSourceModel = dataSourceModel
        super.init(frame: frame, style: style)
        
        self.registerCells()
        self.delegate = self
        self.dataSource = self
    }
    convenience public init(dataSourceModel: DataSource) {
        self.init(dataSourceModel: dataSourceModel, frame: .zero, style: .plain)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Accessors
    private func identifierForCellType(cellType: Int) -> String {
        return String(format: "%li", cellType)
    }
    
    //MARK: Actions
    open func registerCells() {
        for cellType in dataSourceModel.cellTypes {
            register(dataSourceModel.cellClassForType(type: cellType), forCellReuseIdentifier: identifierForCellType(cellType: cellType))
        }
    }
    open func configureCellForIndexPath(cell: DataSourceTableViewCell, type: Int, indexPath: IndexPath) {
        //Subclasses can configure cells here
    }
    
    //MARK: UITableViewDataSource
    open func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceModel.numberOfSections()
    }
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceModel.numberOfItemsInSection(section: section)
    }
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = dataSourceModel.cellTypeForIndexPath(indexPath: indexPath)
        let cellIdentifier = identifierForCellType(cellType: cellType)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if let dataSourceCell = cell as? DataSourceTableViewCell {
            //Pass our model object to the cell so it can configure itself
            dataSourceCell.configureWithModel(model: dataSourceModel.modelObjectForIndexPath(indexPath: indexPath))
            
            //Call configureCell: for further subclass configuration
            configureCellForIndexPath(cell: dataSourceCell, type: cellType, indexPath: indexPath)
        }
        
        return cell
    }
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSourceModel.headerTitleForSection(section: section)
    }
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSourceModel.footerTitleForSection(section: section)
    }
    
    //MARK: UITableViewDelegate
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let title = self.tableView(tableView, titleForHeaderInSection: section)
        
        if let titleLength = title?.count as Int?, titleLength > 0 {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 12)
            
            header.addSubview(label)
            header.addConstraints([
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: header, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: header, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: header, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
                ])
        }
        
        return header
    }
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        let title = self.tableView(tableView, titleForFooterInSection: section)
        
        if let titleLength = title?.count as Int?, titleLength > 0 {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 12)
            
            footer.addSubview(label)
            footer.addConstraints([
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: footer, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: footer, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: footer, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
                ])
        }
        
        return footer
    }
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSourceModel.heightForHeaderInSection(section: section)
    }
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return dataSourceModel.heightForFooterInSection(section: section)
    }
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataSourceModel.selectItemAtIndexPath(indexPath: indexPath)
    }
    
    //MARK: DataSourceReloader
    open func reloadDataAtIndexPath(indexPath: IndexPath) {
        reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    open func reloadDataAtIndexPaths(indexPaths: [IndexPath]) {
        reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
    }
    open func insertRowsAtIndexPaths(indexPaths: [IndexPath]) {
        insertRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
    }
    open func removeRowsAtIndexPaths(indexPaths: [IndexPath]) {
        deleteRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
    }
    open func reloadSections(sections: IndexSet) {
        reloadSections(sections, with: UITableViewRowAnimation.automatic)
    }
    open func insertSections(sections: IndexSet) {
        insertSections(sections, with: UITableViewRowAnimation.automatic)
    }
    open func removeSections(sections: IndexSet) {
        deleteSections(sections, with: UITableViewRowAnimation.automatic)
    }
}
