//
//  DataSourceCollectionView.swift
//  SwiftDataSource
//
//  Created by Rocco Del Priore on 11/25/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import Foundation
import UIKit

open class DataSourceCollectionViewCell: UICollectionViewCell {
    open func configureWithModel(model: DataSourceItem) {
        
    }
}

open class DataSourceCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, DataSourceReloader {
    open let dataSourceModel: DataSource
    
    //MARK: Initializers
    public init(dataSourceModel: DataSource, frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        self.dataSourceModel = dataSourceModel
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        
        self.registerCells()
        
        self.delegate = self
        self.dataSource = self
        self.dataSourceModel.reloader = self
    }
    convenience public init(dataSourceModel: DataSource) {
        self.init(dataSourceModel: dataSourceModel, frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Accessors
    private func identifierForCellType(cellType: Int) -> String {
        return String(format: "%li", cellType)
    }
    
    //MARK: Actions
    open func registerCells() {
        for cellType in dataSourceModel.cellTypes {
            register(dataSourceModel.cellClassForType(type: cellType), forCellWithReuseIdentifier: identifierForCellType(cellType: cellType))
        }
    }
    open func configureCellForIndexPath(cell: DataSourceCollectionViewCell, type: Int, indexPath: IndexPath) {
        //Subclasses can configure cells here
    }
    
    //MARK: UICollectionViewDataSource
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSourceModel.numberOfSections()
    }
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceModel.numberOfItemsInSection(section: section)
    }
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = dataSourceModel.cellTypeForIndexPath(indexPath: indexPath)
        let cellIdentifier = identifierForCellType(cellType: cellType)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        if let dataSourceCell = cell as? DataSourceCollectionViewCell {
            //Pass our model object to the cell so it can configure itself
            dataSourceCell.configureWithModel(model: dataSourceModel.modelObjectForIndexPath(indexPath: indexPath))
            
            //Call configureCell: for further subclass configuration
            configureCellForIndexPath(cell: dataSourceCell, type: cellType, indexPath: indexPath)
        }
        
        return cell
    }
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reuseableView = UICollectionReusableView(frame: CGRect.zero)
        
        var title = ""
        if (kind == UICollectionElementKindSectionHeader) {
            title = dataSourceModel.headerTitleForSection(section: indexPath.section)
        }
        else if (kind == UICollectionElementKindSectionFooter) {
            title = dataSourceModel.footerTitleForSection(section: indexPath.section)
        }
        
        if let titleLength = title.count as Int?, titleLength > 0 {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 12)
            
            reuseableView.addSubview(label)
            reuseableView.addConstraints([
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: reuseableView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: reuseableView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: reuseableView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
                ])
        }
        
        return reuseableView
    }
    
    //MARK: UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        dataSourceModel.selectItemAtIndexPath(indexPath: indexPath)
    }
    
    //MARK: DataSourceReloader
    open func reloadDataAtIndexPath(indexPath: IndexPath) {
        self.performBatchUpdates({
            reloadItems(at: [indexPath])
        }, completion: nil)
    }
    open func reloadDataAtIndexPaths(indexPaths: [IndexPath]) {
        self.performBatchUpdates({
            reloadItems(at: indexPaths)
        }, completion: nil)
    }
    open func insertRowsAtIndexPaths(indexPaths: [IndexPath]) {
        self.performBatchUpdates({
            insertItems(at: indexPaths)
        }, completion: nil)
    }
    open func removeRowsAtIndexPaths(indexPaths: [IndexPath]) {
        self.performBatchUpdates({
            deleteItems(at: indexPaths)
        }, completion: nil)
    }
    open func reloadSections(sections: IndexSet) {
        self.performBatchUpdates({
            reloadSections(sections)
        }, completion: nil)
    }
    open func insertSections(sections: IndexSet) {
        self.performBatchUpdates({
            insertSections(sections)
        }, completion: nil)
    }
    open func removeSections(sections: IndexSet) {
        self.performBatchUpdates({
            deleteSections(sections)
        }, completion: nil)
    }
}
