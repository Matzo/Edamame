//
//  DataSource.swift
//  DataSource
//
//  Created by 松尾 圭祐 on 2016/02/11.
//  Copyright © 2016年 松尾 圭祐. All rights reserved.
//

import UIKit

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
    optional func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
}

// MARK: - EdamameCell
public protocol EdamameCell {
    func configure(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath)
    static func sizeForItem(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) -> CGSize
}

public protocol EdamameSupplementaryView {
    func configure(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath)
    static func sizeForItem(item: Any, collectionView: UICollectionView, section: Int) -> CGSize
}

public extension EdamameCell {
    static func calculateSize<T: UICollectionViewCell where T: EdamameCell>(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath, cell: T, width: CGFloat? = nil) -> CGSize {
        let width = width ?? collectionView.frame.size.width
        let widthConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: width)
        let translatesAutoresizingMaskIntoConstraints = cell.contentView.translatesAutoresizingMaskIntoConstraints
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addConstraint(widthConstraint)

        cell.configure(item, collectionView: collectionView, indexPath: indexPath)
        cell.bounds = CGRectMake(0, 0, width, cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
 
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        cell.contentView.removeConstraint(widthConstraint)
        cell.contentView.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints

        return size
    }
}

public typealias EdamameSelectionHandler = (item: Any, indexPath: NSIndexPath) -> Void
class EdamameItem {
    var item: Any
    var cellType: UICollectionViewCell.Type
    var size: CGSize = CGSize.zero
    var needsLayout: Bool = true
    var calculateSizeInBackground: Bool = false
    var selectionHandler: EdamameSelectionHandler?
    var isFirstAppearing: Bool = true

    init(item: Any, cellType: UICollectionViewCell.Type, calculateSizeInBackground: Bool = false, selection: EdamameSelectionHandler? = nil) {
        self.item = item
        self.cellType = cellType
        self.calculateSizeInBackground = calculateSizeInBackground
        self.selectionHandler = selection
    }
}

class EdamameSupplementaryItem {
    var item: Any
    var viewType: UICollectionReusableView.Type
    var size: CGSize = CGSize.zero
    var needsLayout: Bool = true
    var isFirstAppearing: Bool = true
 
    init(item: Any, viewType: UICollectionReusableView.Type) {
        self.item = item
        self.viewType = viewType
    }
}

// MARK: - EdamameSection
public class EdamameSection {
    private weak var dataSource: Edamame!
    private var items = [EdamameItem]()
    private var supplementaryItems = [String: EdamameSupplementaryItem]()
    private var cellType: UICollectionViewCell.Type

    public var index: Int {
        for (index, section) in dataSource.sections.enumerate() {
            if section === self {
                return index
            }
        }
        return 0
    }
    public var hidden: Bool = false
    public var inset: UIEdgeInsets?

    public init(cellType: UICollectionViewCell.Type? = nil) {
        self.cellType = cellType ?? UICollectionViewCell.self
    }

    public func items<T>(type: T.Type) -> [T] {
        return self.items.filter({$0.item is T}).map({$0.item as! T})
    }
}

// MARK: Public Methods
public extension EdamameSection {
    subscript(index: Int) -> Any {
        get {
            return items[index].item
        }
    }
 
    subscript(kind: String) -> Any? {
        get {
            return supplementaryItems[kind]?.item
        }
    }
 
    func setCellType<T: UICollectionViewCell>(cellType: T.Type) {
        self.cellType = cellType
    }
 
    func setCellType<T: UICollectionViewCell, I: Equatable>(cellType: T.Type, forItem item: I) {
        for cellItem in items {
            if let _item = cellItem.item as? I where _item == item {
                cellItem.cellType = cellType
            }
        }
    }
 
    func setCellType<T: UICollectionViewCell>(cellType: T.Type, forItemAt index: Int) {
        if items.count > index {
            items[index].cellType = cellType
        }
    }

    func appendItem(item: Any, cellType: UICollectionViewCell.Type? = nil, calculateSizeInBackground:Bool = false, selection: EdamameSelectionHandler? = nil) {
        let item = EdamameItem(item: item, cellType: cellType ?? self.cellType, calculateSizeInBackground: calculateSizeInBackground, selection: selection)
        self.items.append(item)
 
    }

    func insertItem(item: Any, atIndex: Int, cellType: UICollectionViewCell.Type? = nil, calculateSizeInBackground:Bool = false, selection: EdamameSelectionHandler? = nil) {
        let item = EdamameItem(item: item, cellType: cellType ?? self.cellType, calculateSizeInBackground: calculateSizeInBackground, selection: selection)
        self.items.insert(item, atIndex: atIndex)
    }
 
    func appendSupplementaryItem(item: Any, kind: String, viewType: UICollectionReusableView.Type? = nil) {
        self.supplementaryItems[kind] = EdamameSupplementaryItem(item: item, viewType: viewType ?? self.cellType)
    }
 
    func removeItemAtIndex(index: Int) {
        self.items.removeAtIndex(index)
    }
 
    func removeAllItems() {
        self.items.removeAll()
    }
 
    func removeSupplementaryItem(kind: String) {
        self.supplementaryItems[kind] = nil
    }
 
    func removeAllSupplementaryItems() {
        self.supplementaryItems.removeAll()
    }
}

// MARK: DataSource
extension EdamameSection {
    func numberOfItemsInCollectionView(collectionView: UICollectionView) -> Int {
        if self.hidden {
            return 0
        } else {
            return items.count
        }
    }
}

// MARK: FLowLayout
extension EdamameSection : FlowLayoutProtocol {
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        let cell = dataSource.dequeueReusableCell(item.cellType.self, forIndexPath: indexPath)
        if let cell = cell as? EdamameCell {
            cell.configure(item.item, collectionView: collectionView, indexPath: indexPath)
            item.isFirstAppearing = false
        }
        return cell
    }

    @objc public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = items[indexPath.item]
        if item.needsLayout && !item.calculateSizeInBackground {
            if let cellType = item.cellType as? EdamameCell.Type {
                item.size = cellType.sizeForItem(item.item, collectionView: collectionView, indexPath: indexPath)
                item.needsLayout = false
            }
        }
 
        // Experimental
        if item.size == CGSize.zero {
            if collectionView.contentSize.width != collectionView.frame.size.width {
                // horizontal scroll
                return CGSize(width: 0, height: collectionView.frame.size.height)
            } else {
                // vertical scroll
                return CGSize(width: collectionView.frame.size.width, height: 0)
            }
        }
        return item.size
    }
 
    @objc public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let item = self.supplementaryItems[UICollectionElementKindSectionHeader] else { return CGSize.zero }
        if item.needsLayout {
            if let viewType = item.viewType as? EdamameSupplementaryView.Type {
                item.size = viewType.sizeForItem(item.item, collectionView: collectionView, section: section)
                item.needsLayout = false
            }
        }
        return item.size
    }
 
    @objc public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let item = self.supplementaryItems[UICollectionElementKindSectionFooter] else { return CGSize.zero }
        if item.needsLayout {
            if let viewType = item.viewType as? EdamameSupplementaryView.Type {
                item.size = viewType.sizeForItem(item.item, collectionView: collectionView, section: section)
                item.needsLayout = false
            }
        }
        return item.size
    }
 
    @objc public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        guard let item = supplementaryItems[kind] else {
            return dataSource.dequeueReusableCell(kind, withReuseType: UICollectionReusableView.self, forIndexPath: indexPath)
        }
        let view = dataSource.dequeueReusableCell(kind, withReuseType: item.viewType, forIndexPath: indexPath)
        if let view = view as? EdamameSupplementaryView {
            view.configure(item.item, collectionView: collectionView, indexPath: indexPath)
            item.isFirstAppearing = false
        }
        return view
    }
    
    @objc public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if let inset = inset {
            return inset
        } else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.sectionInset
        }
        return UIEdgeInsetsZero
    }
}

// MARK: - Edamame
public class Edamame: NSObject {

    /// readonly
    private let _calculateSizeQueue = dispatch_queue_create("matzo.Edamame", DISPATCH_QUEUE_SERIAL)
    private var _collectionView: UICollectionView
    private var _sections = [EdamameSection]()
 
    override init() {
        fatalError("required collectionView")
    }
 
    public init(collectionView: UICollectionView) {
        self._collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.registerClassFromClass(UICollectionViewCell.self)
        self.registerClassFromClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        self.registerClassFromClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
    }
}

// MARK: Public Methods
public extension Edamame {
    // accessor
    public var collectionView: UICollectionView { return _collectionView }
    public var sections: [EdamameSection]       { return _sections       }
 
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

    func createSection(cellType: UICollectionViewCell.Type? = nil, atIndex index: Int? = nil) -> EdamameSection {
        let section = EdamameSection(cellType: cellType)
        if let index = index {
            self.insertSection(section, atIndex: index)
        } else {
            self.appendSection(section)
        }
        return section
    }

    func appendSection(section: EdamameSection) {
        section.dataSource = self
        self._sections.append(section)
    }

    func insertSection(section: EdamameSection, atIndex: Int) {
        section.dataSource = self
        self._sections.insert(section, atIndex: atIndex)
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
        self.calculateSizeInBackground()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    func setNeedsLayout(indexPath: NSIndexPath) {
        guard self.sections.count > indexPath.section else { return }
        guard self.sections[indexPath.section].items.count > indexPath.item else { return }
        
        self.sections[indexPath.section].items[indexPath.item].needsLayout = true
        self.calculateSizeInBackground()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    func reloadData() {
        self.calculateSizeInBackground()
        self.collectionView.reloadData()
    }
 
    func removeItemAtIndexPath(indexPath: NSIndexPath) {
        self[indexPath.section].items.removeAtIndex(indexPath.item)
    }
 
    func removeAllItems() {
        self._sections.removeAll()
    }
 
    func calculateSizeInBackground() {
        if self.sections.filter({ $0.items.filter({ $0.calculateSizeInBackground && $0.needsLayout }).count > 0 }).count == 0 {
            return
        }
        dispatch_async(_calculateSizeQueue) { () -> Void in
            var needsReload = false
            for sectionIndex in 0..<self.sections.count {
                let section = self.sections[sectionIndex]
                for itemIndex in 0..<section.items.count {
                    let item = section.items[itemIndex]
                    guard item.calculateSizeInBackground && item.needsLayout else { continue }
 
                    if let cellType = item.cellType as? EdamameCell.Type {
                        let indexPath = NSIndexPath(forItem: sectionIndex, inSection: itemIndex)
                        item.size = cellType.sizeForItem(item.item, collectionView: self.collectionView, indexPath: indexPath)
                        item.needsLayout = false
                        needsReload = true
                    }
                }
            }
 
            if needsReload {
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.reloadData()
                })
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension Edamame: UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let section = sections[indexPath.section]
        return section.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionItem = sections[section]
        return sectionItem.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sectionItem = sections[section]
        return sectionItem.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let sectionItem = sections[section]
        return sectionItem.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: section)
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        sections[indexPath.section].items[indexPath.item].selectionHandler?(item: self[indexPath], indexPath: indexPath)
    }
}

// MARK: UICollectionViewDataSource
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

    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let section = sections[indexPath.section]
        return section.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
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
                withReuseIdentifier: String(type), forIndexPath: indexPath) as! T
    }
}

// MARK: - UICollectionView
public extension UICollectionView {
    var edamame: Edamame? {
        return dataSource as? Edamame ?? delegate as? Edamame
    }

    func isFirstAppearing(indexPath: NSIndexPath) -> Bool {
        guard let sections = self.edamame?._sections where sections.count > indexPath.section else { return false }
        guard sections[indexPath.section].items.count > indexPath.item else { return false }

        return sections[indexPath.section].items[indexPath.item].isFirstAppearing
    }
}
