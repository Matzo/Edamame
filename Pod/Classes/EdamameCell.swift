//
//  EdamameCell.swift
//  Edamame
//
//  Created by 松尾 圭祐 on 2019/01/29.
//

import Foundation

public protocol EdamameCell {
    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath)
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
}

public extension EdamameCell {
    static func calculateSize<T: UICollectionViewCell>(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath, cell: T, width: CGFloat? = nil) -> CGSize where T: EdamameCell {
        cell.configure(item, collectionView: collectionView, indexPath: indexPath)

        var targetSize = UIView.layoutFittingCompressedSize
        targetSize.width = floor(width ?? collectionView.frame.size.width)

        return cell.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
}

public typealias EdamameSelectionHandler = (_ item: Any, _ indexPath: IndexPath) -> Void
class EdamameItem {
    var item: Any
    var cellType: UICollectionViewCell.Type
    var size: CGSize = CGSize.zero
    var needsLayout: Bool = true
    var selectionHandler: EdamameSelectionHandler?
    var isFirstAppearing: Bool = true

    init(item: Any, cellType: UICollectionViewCell.Type, selection: EdamameSelectionHandler? = nil) {
        self.item = item
        self.cellType = cellType
        self.selectionHandler = selection
    }
}
