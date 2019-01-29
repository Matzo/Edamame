//
//  EdamameSection.swift
//  Edamame
//
//  Created by 松尾 圭祐 on 2019/01/29.
//

import Foundation

// MARK: - EdamameSection
open class EdamameSection {

    public typealias CellConfigureHandler = (Any, UICollectionView, UICollectionViewCell, IndexPath) -> Void
    public typealias SupplementaryViewConfigureHandler = (Any, UICollectionView, UICollectionReusableView, String, IndexPath) -> Void

    public typealias CellSizingHandler = (Any, UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize
    public typealias SupplementaryViewSizingHandler = (Any, UICollectionView, UICollectionViewLayout, String, Int) -> CGSize

    internal weak var dataSource: Edamame!
    internal var items = [EdamameItem]()
    internal var supplementaryItems = [String: EdamameSupplementaryItem]()
    internal var cellType: UICollectionViewCell.Type
    public var cellConfigureHandler: CellConfigureHandler?
    public var cellSizingHandler: CellSizingHandler?
    public var supplementaryViewConfigureHandler: SupplementaryViewConfigureHandler?
    public var supplementaryViewSizingHandler: SupplementaryViewSizingHandler?

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

    func itemIndexOf<T: Equatable>(_ item: T) -> Int? {
        return self.items.firstIndex(where: { (edamameItem) -> Bool in
            guard let existItem = edamameItem.item as? T else { return false }
            return existItem == item
        })
    }

    func itemIndexOf<T>(_ type: T.Type, where: (T) -> Bool) -> Int? {
        return self.items.firstIndex(where: { (edamameItem) -> Bool in
            guard let existItem = edamameItem.item as? T else { return false }
            return `where`(existItem)
        })
    }

    func itemIndexOf<T>(where: (T) -> Bool) -> Int? {
        return self.items.firstIndex(where: { (edamameItem) -> Bool in
            guard let existItem = edamameItem.item as? T else { return false }
            return `where`(existItem)
        })
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

    func appendItem(_ item: Any, cellType: UICollectionViewCell.Type? = nil, selection: EdamameSelectionHandler? = nil) {
        let item = EdamameItem(item: item, cellType: cellType ?? self.cellType, selection: selection)
        dataSource?._updates.append(.append(item: item, section: index))
    }

    func insertItem(_ item: Any, atIndex: Int, cellType: UICollectionViewCell.Type? = nil, selection: EdamameSelectionHandler? = nil) {
        let item = EdamameItem(item: item, cellType: cellType ?? self.cellType, selection: selection)
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
        cellConfigureHandler?(item.item, collectionView, cell, indexPath)
        return cell
    }

    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard !self.hidden else { return CGSize.zero }
        guard items.count > indexPath.item else { return CGSize.zero }
        let item = items[indexPath.item]
        if item.needsLayout {
            if let cellType = item.cellType as? EdamameCell.Type {
                item.size = cellType.sizeForItem(item.item, collectionView: collectionView, indexPath: indexPath)
                item.needsLayout = false
                if let handler = cellSizingHandler {
                    item.size = handler(item.item, collectionView, collectionViewLayout, indexPath)
                }
            }
        }
        return item.size
    }

    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard !self.hidden else { return CGSize.zero }
        guard let item = self.supplementaryItems[UICollectionView.elementKindSectionHeader] else { return CGSize.zero }
        if item.needsLayout {
            if let viewType = item.viewType as? EdamameSupplementaryView.Type {
                item.size = viewType.sizeForItem(item.item, collectionView: collectionView, section: section)
                item.needsLayout = false
                if let handler = supplementaryViewSizingHandler {
                    item.size = handler(item.item, collectionView, collectionViewLayout, UICollectionView.elementKindSectionHeader, section)
                }
            }
        }
        return item.size
    }

    @objc public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard !self.hidden else { return CGSize.zero }
        guard let item = self.supplementaryItems[UICollectionView.elementKindSectionFooter] else { return CGSize.zero }
        if item.needsLayout {
            if let viewType = item.viewType as? EdamameSupplementaryView.Type {
                item.size = viewType.sizeForItem(item.item, collectionView: collectionView, section: section)
                item.needsLayout = false
                if let handler = supplementaryViewSizingHandler {
                    item.size = handler(item.item, collectionView, collectionViewLayout, UICollectionView.elementKindSectionFooter, section)
                }
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
        supplementaryViewConfigureHandler?(item.item, collectionView, view, kind, indexPath)
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

