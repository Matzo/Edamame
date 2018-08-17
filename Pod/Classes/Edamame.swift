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
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    @objc optional func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView
    @objc optional func collectionView(_ collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath)
}

// MARK: - EdamameCell
public protocol EdamameCell {
    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath)
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
}

public protocol EdamameSupplementaryView {
    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath)
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, section: Int) -> CGSize
}

public extension EdamameCell {
    static func calculateSize<T: UICollectionViewCell>(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath, cell: T, width: CGFloat? = nil) -> CGSize where T: EdamameCell {
        let width = width ?? collectionView.frame.size.width
        let widthConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: width)
        let translatesAutoresizingMaskIntoConstraints = cell.contentView.translatesAutoresizingMaskIntoConstraints
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addConstraint(widthConstraint)

        cell.configure(item, collectionView: collectionView, indexPath: indexPath)
        cell.bounds = CGRect(x: 0, y: 0, width: width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
 
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        cell.contentView.removeConstraint(widthConstraint)
        cell.contentView.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints

        return size
    }
}

public typealias EdamameSelectionHandler = (_ item: Any, _ indexPath: IndexPath) -> Void
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
open class EdamameSection {
    fileprivate weak var dataSource: Edamame!
    fileprivate var items = [EdamameItem]()
    fileprivate var supplementaryItems = [String: EdamameSupplementaryItem]()
    fileprivate var cellType: UICollectionViewCell.Type
    
    open var numberOfItems: Int {
        return items.count
    }

    open var numberOfVisibleItems: Int {
        return hidden ? 0 : items.count
    }

    open var index: Int {
        for (index, section) in dataSource.sections.enumerated() {
            if section === self {
                return index
            }
        }
        return 0
    }
    open var hidden: Bool = false {
        didSet {
            self.dataSource?.setNeedsLayout()
        }
    }
    open var inset: UIEdgeInsets?
    open var minimumLineSpacing: CGFloat?
    open var minimumInteritemSpacing: CGFloat?

    public init(cellType: UICollectionViewCell.Type? = nil) {
        self.cellType = cellType ?? UICollectionViewCell.self
    }

    open func items<T>(_ type: T.Type) -> [T] {
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
 
    func setCellType<T: UICollectionViewCell>(_ cellType: T.Type) {
        self.cellType = cellType
    }
 
    func setCellType<T: UICollectionViewCell, I: Equatable>(_ cellType: T.Type, forItem item: I) {
        for cellItem in items {
            if let _item = cellItem.item as? I, _item == item {
                cellItem.cellType = cellType
            }
        }
    }
 
    func setCellType<T: UICollectionViewCell>(_ cellType: T.Type, forItemAt index: Int) {
        if items.count > index {
            items[index].cellType = cellType
        }
    }

    func appendItem(_ item: Any, cellType: UICollectionViewCell.Type? = nil, calculateSizeInBackground:Bool = false, selection: EdamameSelectionHandler? = nil) {
        let item = EdamameItem(item: item, cellType: cellType ?? self.cellType, calculateSizeInBackground: calculateSizeInBackground, selection: selection)
        dataSource?._updates.append(.append(item: item, section: index))
    }

    func insertItem(_ item: Any, atIndex: Int, cellType: UICollectionViewCell.Type? = nil, calculateSizeInBackground:Bool = false, selection: EdamameSelectionHandler? = nil) {
        let item = EdamameItem(item: item, cellType: cellType ?? self.cellType, calculateSizeInBackground: calculateSizeInBackground, selection: selection)
        dataSource?._updates.append(.insert(item: item, indexPath: IndexPath(item: atIndex, section: index)))
    }
 
    func appendSupplementaryItem(_ item: Any, kind: String, viewType: UICollectionReusableView.Type? = nil) {
        let item = EdamameSupplementaryItem(item: item, viewType: viewType ?? self.cellType)
        dataSource?._updates.append(.appendSupplementary(item: item, kind: kind, section: index))
    }
 
    func removeItemAtIndex(_ index: Int) {
        let indexPath = IndexPath(item: index, section: self.index)
        dataSource?._updates.append(.delete(indexPaths: [indexPath]))
    }

    func removeItems<T>(type: T.Type) {
        var removeIndexPaths: [IndexPath] = []
        removeIndexPaths = self.items.enumerated().filter({ $0.1.item is T }).map({ IndexPath(item: $0.0, section: self.index) })
        if removeIndexPaths.count > 0 {
            dataSource?._updates.append(.delete(indexPaths: removeIndexPaths))
        }
    }

    func removeAllItems() {
        guard items.count > 0 else { return }
        var indexPaths: [IndexPath] = []
        for i in 0..<items.count {
            indexPaths.append(IndexPath(item: i, section: index))
        }
        dataSource?._updates.append(.delete(indexPaths: indexPaths))
    }
 
    func removeSupplementaryItem(_ kind: String) {
        dataSource?._updates.append(.deleteSupplementary(kind: kind, section: index))
        self.dataSource.collectionView.collectionViewLayout.invalidateLayout()
    }
 
    func removeAllSupplementaryItems() {
        for (kind, _) in supplementaryItems {
            self.supplementaryItems[kind] = nil
            dataSource?._updates.append(.deleteSupplementary(kind: kind, section: index))
        }
    }

    func reloadData(animated: Bool = false) {
        dataSource.reloadSection(section: index, animated: animated)
    }
}

// MARK: DataSource
extension EdamameSection {
    func numberOfItemsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return numberOfVisibleItems
    }
}

// MARK: FLowLayout
extension EdamameSection : FlowLayoutProtocol {
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        let cell = dataSource.dequeueReusableCell(item.cellType.self, forIndexPath: indexPath)
        if let cell = cell as? EdamameCell {
            cell.configure(item.item, collectionView: collectionView, indexPath: indexPath)
            item.isFirstAppearing = false
        }
        return cell
    }

    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard !self.hidden else { return CGSize.zero }
        guard items.count > indexPath.item else { return CGSize.zero }
        let item = items[indexPath.item]
        if item.needsLayout && !item.calculateSizeInBackground {
            if let cellType = item.cellType as? EdamameCell.Type {
                item.size = cellType.sizeForItem(item.item, collectionView: collectionView, indexPath: indexPath)
                item.needsLayout = false
            }
        }
        return item.size
    }
 
    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard !self.hidden else { return CGSize.zero }
        guard let item = self.supplementaryItems[UICollectionElementKindSectionHeader] else { return CGSize.zero }
        if item.needsLayout {
            if let viewType = item.viewType as? EdamameSupplementaryView.Type {
                item.size = viewType.sizeForItem(item.item, collectionView: collectionView, section: section)
                item.needsLayout = false
            }
        }
        return item.size
    }

    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard !self.hidden else { return CGSize.zero }
        guard let item = self.supplementaryItems[UICollectionElementKindSectionFooter] else { return CGSize.zero }
        if item.needsLayout {
            if let viewType = item.viewType as? EdamameSupplementaryView.Type {
                item.size = viewType.sizeForItem(item.item, collectionView: collectionView, section: section)
                item.needsLayout = false
            }
        }
        return item.size
    }
 
    @objc public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
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
    
    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if self.hidden {
            return UIEdgeInsets.zero
        }
        if let inset = inset {
            return inset
        } else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.sectionInset
        }
        return UIEdgeInsets.zero
    }

    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if let minimumLineSpacing = self.minimumLineSpacing {
            return minimumLineSpacing
        } else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.minimumLineSpacing
        } else {
            return 0
        }
    }
    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if let minimumInteritemSpacing = self.minimumInteritemSpacing {
            return minimumInteritemSpacing
        } else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.minimumInteritemSpacing
        } else {
            return 0
        }
    }
}

// MARK: - Edamame
open class Edamame: NSObject {

    enum UpdateType {
        case append(item: EdamameItem, section: Int)
        case insert(item: EdamameItem, indexPath: IndexPath)
        case delete(indexPaths: [IndexPath])
        case appendSupplementary(item: EdamameSupplementaryItem, kind: String, section: Int)
        case deleteSupplementary(kind: String, section: Int)
    }

    /// readonly
    fileprivate let _calculateSizeQueue = DispatchQueue(label: "matzo.Edamame", attributes: [])
    fileprivate var _collectionView: UICollectionView
    fileprivate var _sections = [EdamameSection]()
    fileprivate var _updates: [UpdateType] = []

    // public
    var hasAcyncSizingItem: Bool {
        for update in _updates {
            switch update {
            case .append(let item, _):
                if item.calculateSizeInBackground && item.needsLayout {
                    return true
                }
            case .insert(let item, _):
                if item.calculateSizeInBackground && item.needsLayout {
                    return true
                }
            case .delete(_):
                break
            case .appendSupplementary(_, _, _), .deleteSupplementary(_, _):
                break
            }
        }
        return false
    }

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
 
    subscript(index: IndexPath) -> Any {
        get {
            return self[index.section][index.item]
        }
    }

    func createSection(_ cellType: UICollectionViewCell.Type? = nil, atIndex index: Int? = nil) -> EdamameSection {
        let section = EdamameSection(cellType: cellType)
        if let index = index {
            self.insertSection(section, atIndex: index)
        } else {
            self.appendSection(section)
        }
        section.reloadData(animated: false)
        return section
    }

    func appendSection(_ section: EdamameSection) {
        section.dataSource = self
        self._sections.append(section)
    }

    func insertSection(_ section: EdamameSection, atIndex: Int) {
        section.dataSource = self
        self._sections.insert(section, at: atIndex)
    }

    func reloadSections(animated: Bool = true) {
        if self.sections.count > 0 {
            for section in 0..<self.sections.count {
                self.reloadSection(section: section, animated: animated)
            }
        }
    }

    func reloadSection(section: Int, animated: Bool = false) {
        if animated && !self[section].hidden {
            applyUpdates(section: section)
            self.collectionView.reloadSections([section])
        } else {
            UIView.performWithoutAnimation {
                applyUpdates(section: section)
                self.collectionView.reloadData()
            }
        }

    }

    func setNeedsLayout(animated: Bool = false) {
        let block = {
            for section in self.sections {
                for item in section.items {
                    item.needsLayout = true
                }
                for (_, supplementaryItem) in section.supplementaryItems {
                    supplementaryItem.needsLayout = true
                }
            }
            self.calculateSizeInBackground()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                block()
            }) { (done) in
            }
        } else {
            block()
        }
    }

    func setNeedsLayout(_ indexPath: IndexPath, animated: Bool = false) {
        guard self.sections.count > indexPath.section else { return }
        guard self.sections[indexPath.section].items.count > indexPath.item else { return }

        let block = {
            self.sections[indexPath.section].items[indexPath.item].needsLayout = true
            self.calculateSizeInBackground()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                block()
            }) { (done) in
            }
        } else {
            block()
        }
    }

    func reloadData(animated: Bool = false) {
        self.calculateSizeInBackground()
        self.reloadHiddenSections()
        if animated && !hasAcyncSizingItem {
            self.collectionView.performBatchUpdates({
                self.applyUpdatesAnimating()
            }, completion: { (done) in
                self.collectionView.reloadData()
            })
        } else {
            applyUpdates()
            self.collectionView.reloadData()
        }
    }

    func reloadHiddenSections() {
        sections.forEach { (section) in
            guard section.hidden else { return }
            reloadSection(section: section.index, animated: false)
        }
    }

    func applyUpdates() {
        for update in self._updates {
            switch update {
            case .append(let item, let section):
                self[section].items.append(item)
            case .insert(let item, let indexPath):
                self[indexPath.section].items.insert(item, at: indexPath.item)
            case .delete(let indexPaths):
                var indexListPerSection: [[Int]] = []
                for section in 0..<self.collectionView.numberOfSections {
                    indexListPerSection.append(indexPaths.filter({ $0.section == section }).map({ $0.item }))
                }
                for (section, indexList) in indexListPerSection.enumerated() {
                    let section = self[section]
                    for removeIndex in indexList.sorted(by: >) {
                        section.items.remove(at: removeIndex)
                    }
                }
            case .appendSupplementary(let item, let kind, let section):
                self[section].supplementaryItems[kind] = item
            case .deleteSupplementary(let kind, let section):
                self[section].supplementaryItems[kind] = nil
            }
        }
        self._updates.removeAll()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    func applyUpdates(section sectionIndex: Int) {
        for update in self._updates {
            switch update {
            case .append(let item, let section):
                guard section == sectionIndex else { continue }

                self[section].items.append(item)
            case .insert(let item, let indexPath):
                guard indexPath.section == sectionIndex else { continue }

                self[indexPath.section].items.insert(item, at: indexPath.item)
            case .delete(let indexPaths):
                var indexListPerSection: [[Int]] = []
                for _section in 0..<self.collectionView.numberOfSections {
                    indexListPerSection.append(indexPaths.filter({ $0.section == _section }).map({ $0.item }))
                }
                for (_section, indexList) in indexListPerSection.enumerated() {
                    guard _section == sectionIndex else { continue }

                    let section = self[_section]
                    for removeIndex in indexList.sorted(by: >) {
                        section.items.remove(at: removeIndex)
                    }
                }
            case .appendSupplementary(let item, let kind, let section):
                guard section == sectionIndex else { continue }

                self[section].supplementaryItems[kind] = item
            case .deleteSupplementary(let kind, let section):
                guard section == sectionIndex else { continue }

                self[section].supplementaryItems[kind] = nil
            }
        }
        var remainedUpdates: [UpdateType] = []
        for update in _updates {
            switch update {
            case .append(_, let section):
                if section != sectionIndex {
                    remainedUpdates.append(update)
                }
            case .insert(_, let indexPath):
                if indexPath.section != sectionIndex {
                    remainedUpdates.append(update)
                }
            case .delete(let indexPaths):
                let remainedDeleteIndexPaths: [IndexPath] = indexPaths.filter({ $0.section != sectionIndex })
                if remainedDeleteIndexPaths.count > 0 {
                    remainedUpdates.append(.delete(indexPaths: remainedDeleteIndexPaths))
                }
            case .appendSupplementary(_, _, let section):
                if section != sectionIndex {
                    remainedUpdates.append(update)
                }
            case .deleteSupplementary(_, let section):
                if section != sectionIndex {
                    remainedUpdates.append(update)
                }
            }
        }
        self._updates = remainedUpdates
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    func applyUpdatesAnimating() {
        var adding: [IndexPath] = []
        var deleting: [IndexPath] = []
        for update in self._updates {
            switch update {
            case .append(let item, let section):
                let addingCount = itemsCount(indexPaths: adding, inSection: section)
                let deletingCount = itemsCount(indexPaths: deleting, inSection: section)
                let indexPath = IndexPath(item: max(self.collectionView.numberOfItems(inSection: section) - deletingCount + addingCount, 0), section: section)
                self[section].items.append(item)
                if deleting.contains(indexPath) {
                    deleting = deleting.filter({ $0 != indexPath })
                } else {
                    adding.append(indexPath)
                }
            case .insert(let item, let indexPath):
                self[indexPath.section].items.insert(item, at: indexPath.item)
                if deleting.contains(indexPath) {
                    deleting = deleting.filter({ $0 != indexPath })
                } else {
                    adding.append(indexPath)
                }
            case .delete(let indexPaths):
                var indexListPerSection: [[Int]] = []
                var deleteIndexPaths: [IndexPath] = []
                for section in 0..<self.collectionView.numberOfSections {
                    indexListPerSection.append(indexPaths.filter({ $0.section == section }).map({ $0.item }))
                }
                for (section, indexList) in indexListPerSection.enumerated() {
                    let section = self[section]
                    for removeIndex in indexList.sorted(by: >) {
                        section.items.remove(at: removeIndex)
                    }
                }
                for indexPath in indexPaths {
                    if adding.contains(indexPath) {
                        adding = adding.filter({ $0 != indexPath })
                    } else {
                        deleting.append(indexPath)
                        deleteIndexPaths.append(indexPath)
                    }
                }
            case .appendSupplementary(let item, let kind, let section):
                self[section].supplementaryItems[kind] = item
            case .deleteSupplementary(let kind, let section):
                self[section].supplementaryItems[kind] = nil
            }
        }
        self.collectionView.insertItems(at: adding)
        self.collectionView.deleteItems(at: deleting)
        self._updates.removeAll()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func itemsCount(indexPaths: [IndexPath], inSection section: Int) -> Int {
        return indexPaths.filter({ $0.section == section }).count
    }

    func removeItemAtIndexPath(_ indexPath: IndexPath) {
        self[indexPath.section].removeItemAtIndex(indexPath.item)
    }

    func removeAllItems() {
        self._sections.forEach({ $0.removeAllItems() })
    }

    func removeSections(indexSet: IndexSet, animated: Bool = false) {
        guard indexSet.filter({ self._sections.count > $0 }).count == indexSet.count else { return }
        var filteredSections: [EdamameSection] = []
        for (index, section) in self._sections.enumerated() {
            if !indexSet.contains(index) {
                filteredSections.append(section)
            }
        }
        if animated {
            self.collectionView.performBatchUpdates({
                self._sections = filteredSections
                self.collectionView.deleteSections(indexSet)
            }, completion: { (done) in
                self.collectionView.reloadData()
            })
        } else {
            self._sections = filteredSections
            self.collectionView.reloadData()
        }
    }

    func removeSection(index: Int, animated: Bool = false) {
        self.removeSections(indexSet: [index], animated: animated)
    }

    func calculateSizeInBackground() {
        if !hasAcyncSizingItem {
            return
        }
        _calculateSizeQueue.async { () -> Void in
            var needsReload = false
            for sectionIndex in 0..<self.sections.count {
                let section = self.sections[sectionIndex]
                for itemIndex in 0..<section.items.count {
                    let item = section.items[itemIndex]
                    guard item.calculateSizeInBackground && item.needsLayout else { continue }
 
                    if let cellType = item.cellType as? EdamameCell.Type {
                        let indexPath = IndexPath(item: sectionIndex, section: itemIndex)
                        item.size = cellType.sizeForItem(item.item, collectionView: self.collectionView, indexPath: indexPath)
                        item.needsLayout = false
                        needsReload = true
                    }
                }
            }
 
            if needsReload {
                DispatchQueue.main.sync(execute: { () -> Void in
                    self.collectionView.reloadData()
                })
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension Edamame: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if sections.count > indexPath.section {
            let section = sections[indexPath.section]
            return section.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        } else {
            return CGSize.zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if sections.count > section {
            let sectionItem = sections[section]
            return sectionItem.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
        } else {
            return CGSize.zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if sections.count > section {
            let sectionItem = sections[section]
            return sectionItem.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
        } else {
            return CGSize.zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if sections.count > section {
            let sectionItem = sections[section]
            return sectionItem.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: section)
        } else {
            return UIEdgeInsets.zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sections[indexPath.section].items[indexPath.item].selectionHandler?(self[indexPath], indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if sections.count > section {
            return sections[section].collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: section)
        } else {
            return 0
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if sections.count > section {
            return sections[section].collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAtIndex: section)
        } else {
            return 0
        }
    }
}

// MARK: UICollectionViewDataSource
extension Edamame: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
 
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = sections[section]
        return section.numberOfItemsInCollectionView(collectionView)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        return section.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = sections[indexPath.section]
        return section.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
}

// MARK: - Utils
public extension Edamame {
    func registerNibFromClass<T: UICollectionViewCell>(_ type: T.Type) {
        let className = String(describing: type)
        let nib = UINib(nibName: className, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: className)
    }
 
    func registerNibFromClass<T: UICollectionReusableView>(_ type: T.Type, forSupplementaryViewOfKind kind: String) {
        let className = String(describing: type)
        let nib = UINib(nibName: className, bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }
 
    func registerClassFromClass<T: UICollectionViewCell>(_ type: T.Type) {
        let className = String(describing: type)
        collectionView.register(T.self, forCellWithReuseIdentifier: className)
    }
 
    func registerClassFromClass<T: UICollectionReusableView>(_ type: T.Type, forSupplementaryViewOfKind kind: String) {
        let className = String(describing: type)
        collectionView.register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }
 
    func dequeueReusableCell<T: UICollectionViewCell>(_ type: T.Type,
        forIndexPath indexPath: IndexPath) -> T {
            return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
 
    func dequeueReusableCell<T: UICollectionReusableView>(_ kind: String, withReuseType type: T.Type,
        forIndexPath indexPath: IndexPath) -> T {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
}

// MARK: - UICollectionView
public extension UICollectionView {
    var edamame: Edamame? {
        return dataSource as? Edamame ?? delegate as? Edamame
    }

    func isFirstAppearing(_ indexPath: IndexPath) -> Bool {
        guard let sections = self.edamame?._sections, sections.count > indexPath.section else { return false }
        guard sections[indexPath.section].items.count > indexPath.item else { return false }

        return sections[indexPath.section].items[indexPath.item].isFirstAppearing
    }
}
