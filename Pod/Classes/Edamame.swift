//
//  DataSource.swift
//  DataSource
//
//  Created by 松尾 圭祐 on 2016/02/11.
//  Copyright © 2016年 松尾 圭祐. All rights reserved.
//

import UIKit

open class Edamame: NSObject {

    enum UpdateType {
        case append(item: EdamameItem, section: Int)
        case insert(item: EdamameItem, indexPath: IndexPath)
        case delete(indexPaths: [IndexPath])
        case appendSupplementary(item: EdamameSupplementaryItem, kind: String, section: Int)
        case deleteSupplementary(kind: String, section: Int)
    }

    // readonly
    internal var _collectionView: UICollectionView
    internal var _sections = [EdamameSection]()
    internal var _updates: [UpdateType] = []

    // public
    override init() {
        fatalError("required collectionView")
    }

    public init(collectionView: UICollectionView) {
        self._collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.registerClassFromClass(UICollectionViewCell.self)
        self.registerClassFromClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        self.registerClassFromClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
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
        self.reloadHiddenSections()
        if animated {
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

    internal func itemsCount(indexPaths: [IndexPath], inSection section: Int) -> Int {
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
