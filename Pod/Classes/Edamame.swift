//
//  DataSource.swift
//  DataSource
//
//  Created by 松尾 圭祐 on 2016/02/11.
//  Copyright © 2016年 松尾 圭祐. All rights reserved.
//

import UIKit

// MARK: - EdamameCell
public protocol EdamameCell {
    func configure(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath)
    static func sizeForItem(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) -> CGSize
}

class CollectionViewItem {
    var item: Any
    var cellType: UICollectionViewCell.Type
    var size: CGSize = CGSizeZero
    var needsLayout: Bool = true
    init(item: Any, cellType: UICollectionViewCell.Type) {
        self.item = item
        self.cellType = cellType
    }
}

// MARK: - FlowLayoutProtocol
@objc public protocol FlowLayoutProtocol {
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    optional func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    optional func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
}

// MARK: - EdamameSection
public class EdamameSection {
    private var items = [CollectionViewItem]()
    private var section: Int = 0
    private var cellType: UICollectionViewCell.Type
    private weak var dataSource: Edamame!
    
    public var hidden: Bool = false
    
    public init(cellType: UICollectionViewCell.Type? = nil) {
        self.cellType = cellType ?? UICollectionViewCell.self
    }

    // MARK: DataSource
    func numberOfItemsInCollectionView(collectionView: UICollectionView) -> Int {
        if self.hidden {
            return 0
        } else {
            return items.count
        }
    }
}
public extension EdamameSection {
    subscript(index: Int) -> Any {
        get {
            return items[index].item
        }
    }

    public func appendItem(item: Any, cellType: UICollectionViewCell.Type? = nil) {
        self.items.append(CollectionViewItem(item: item, cellType: cellType ?? self.cellType))
    }
}

extension EdamameSection : FlowLayoutProtocol {
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        let cell = dataSource.dequeueReusableCell(item.cellType.self, forIndexPath: indexPath)
        if let cell = cell as? EdamameCell {
            cell.configure(item.item, collectionView: collectionView, indexPath: indexPath)
        }
        return cell
    }

    // MARK: FLowLayout
    @objc public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = items[indexPath.item]
        if item.needsLayout {
            if let cellType = item.cellType as? EdamameCell.Type {
                item.size = cellType.sizeForItem(item.item, collectionView: collectionView, indexPath: indexPath)
                item.needsLayout = false
            }
        }
        return item.size
    }
}

// MARK: - Edamame
public class Edamame : NSObject {
    private var sections = [EdamameSection]()
    private var collectionView: UICollectionView
    
    override init() {
        fatalError("required collectionView")
    }
    
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
}

// MARK: - Edamame Public Methods
public extension Edamame {
    subscript(index: Int) -> EdamameSection {
        get {
            if sections.count > index {
                return self.sections[index]
            } else {
                var section = self.createSection()
                while self.sections.count <= index {
                    section = self.createSection()
                }
                return section
            }
        }
    }
    subscript(index: NSIndexPath) -> Any {
        get {
            return self[index.section][index.item]
        }
    }

    func createSection(cellType: UICollectionViewCell.Type? = nil) -> EdamameSection {
        let section = EdamameSection(cellType: cellType)
        self.appendSection(section)
        return section
    }
    
    func appendSection(section: EdamameSection) {
        section.section = self.sections.count
        section.dataSource = self
        self.sections.append(section)
    }
    
    func reloadSections(animated animated: Bool = false) {
        if self.sections.count > 0 {
            let range = NSIndexSet(indexesInRange: NSMakeRange(0, self.sections.count))
            if animated {
                self.collectionView.reloadSections(range)
            } else {
                UIView.performWithoutAnimation({ () -> Void in
                    self.collectionView.reloadSections(range)
                })
            }
        }
    }
    
    func setNeedsLayout() {
        for section in self.sections {
            for item in section.items {
                item.needsLayout = true
            }
        }
        self.reloadSections(animated: false)
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension Edamame: UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let section = sections[indexPath.section]
        return section.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }
}

// MARK: - UICollectionViewDataSource
extension Edamame: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = sections[section]
        return section.numberOfItemsInCollectionView(collectionView)
    }
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        return section.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
}

// MARK: - Utils
public extension Edamame {
    func registerNibFromClass<T: UICollectionViewCell>(type: T.Type) {
        let className = String(T)
        let nib = UINib(nibName: className, bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: className)
    }
    
    func registerNibFromClass<T: UICollectionReusableView>(type: T.Type, forSupplementaryViewOfKind kind: String) {
        let className = String(T)
        let nib = UINib(nibName: className, bundle: nil)
        collectionView.registerNib(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }
    
    func registerClassFromClass<T: UICollectionViewCell>(type: T.Type) {
        let className = String(T)
        collectionView.registerClass(T.self, forCellWithReuseIdentifier: className)
    }
    
    func registerClassFromClass<T: UICollectionReusableView>(type: T.Type, forSupplementaryViewOfKind kind: String) {
        let className = String(T)
        collectionView.registerClass(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(type: T.Type,
        forIndexPath indexPath: NSIndexPath) -> T {
            return collectionView.dequeueReusableCellWithReuseIdentifier(String(type), forIndexPath: indexPath) as! T
    }
    
    func dequeueReusableCell<T: UICollectionReusableView>(kind: String, withReuseType type: T.Type,
        forIndexPath indexPath: NSIndexPath) -> T {
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                withReuseIdentifier: String(T), forIndexPath: indexPath) as! T
    }
}
