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
        if let attributedSubtitle = model.attributedSubtitle {
            detailTextLabel?.attributedText = attributedSubtitle
            detailTextLabel?.numberOfLines = 0
            detailTextLabel?.lineBreakMode = .byWordWrapping
        }
        else {
            detailTextLabel?.text = model.subtitle
        }
        
        imageView?.image = model.image
        accessoryType = model.tableViewCellAccessoryType
    }
}

open class DataSourceTableView: UITableView, UITableViewDataSource, UITableViewDelegate, DataSourceReloader {
    public let dataSourceModel: DataSource
    
    //MARK: Initializers
    public init(dataSourceModel: DataSource, frame: CGRect, style: UITableView.Style) {
        self.dataSourceModel = dataSourceModel
        super.init(frame: frame, style: style)

        self.registerCells()
        self.attachRefreshControl()
        self.delegate = self
        self.dataSource = self
        self.dataSourceModel.reloader = self
        
        if self.dataSourceModel.isLoading {
            self.startLoading()
        }
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
    @objc(startLoading) open func startLoading() {
        self.refreshControl?.beginRefreshing()
    }
    @objc(finishLoading) open func finishLoading() {
        self.refreshControl?.endRefreshing()
    }
    open func attachRefreshControl() {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self.dataSourceModel, action: #selector(DataSource.refreshData), for: .valueChanged)
        }
    }
    open func dettachRefreshControl() {
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
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
                NSLayoutConstraint.init(item: label, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: header, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: header, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: header, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0)
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
                NSLayoutConstraint.init(item: label, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: footer, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: footer, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: footer, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0)
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
        reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        self.refreshControl?.endRefreshing()
    }
    open func reloadDataAtIndexPaths(indexPaths: [IndexPath]) {
        reloadRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
        self.refreshControl?.endRefreshing()
    }
    open func insertRowsAtIndexPaths(indexPaths: [IndexPath]) {
        insertRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
        self.refreshControl?.endRefreshing()
    }
    open func removeRowsAtIndexPaths(indexPaths: [IndexPath]) {
        deleteRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
        self.refreshControl?.endRefreshing()
    }
    open func reloadSections(sections: IndexSet) {
        reloadSections(sections, with: UITableView.RowAnimation.automatic)
        self.refreshControl?.endRefreshing()
    }
    open func insertSections(sections: IndexSet) {
        insertSections(sections, with: UITableView.RowAnimation.automatic)
        self.refreshControl?.endRefreshing()
    }
    open func removeSections(sections: IndexSet) {
        deleteSections(sections, with: UITableView.RowAnimation.automatic)
        self.refreshControl?.endRefreshing()
    }
}

open class DataSourceTableViewController: UIViewController {
    public let tableView: DataSourceTableView
    public required init(dataSourceModel: DataSource) {
        self.tableView = DataSourceTableView(dataSourceModel: dataSourceModel)
        super.init(nibName: nil, bundle: nil)
        
        //Set Properties
        self.view.backgroundColor = .white
        
        //Add Subviews
        self.view.addSubview(self.tableView)
        
        //Set Constraints
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
