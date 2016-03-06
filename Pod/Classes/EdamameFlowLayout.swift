//
//  EdamameFlowLayout.swift
//  Pods
//
//  Created by Matsuo Keisuke on 3/5/16.
//
//

import UIKit

class EdamameFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        self.registerClass(EdamameSeparator.self, forDecorationViewOfKind: String(EdamameSeparator.self))
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElementsInRect(rect) ?? []
        var newAttrs: [UICollectionViewLayoutAttributes] = []
        
        for attr in attributes {
            newAttrs.append(attr)
            attr.zIndex = 0
            if let newAttr = layoutAttributesForDecorationViewOfKind(String(EdamameSeparator.self), atIndexPath: attr.indexPath) {
                newAttr.zIndex = 100
                newAttrs.append(newAttr)
            }
        }
        return newAttrs
    }
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        UITableView().rowHeight = UITableViewAutomaticDimension
        UICollectionViewCell
        UICollectionViewFlowLayout().estimatedItemSize
        if elementKind == String(EdamameSeparator.self) {
            let attr = UICollectionViewLayoutAttributes(forDecorationViewOfKind: String(EdamameSeparator.self), withIndexPath: indexPath)
            let sectionCount = collectionView?.numberOfItemsInSection(indexPath.section) ?? 0
            if let rect = self.layoutAttributesForItemAtIndexPath(indexPath)?.frame where sectionCount - 1 != indexPath.item {
                attr.frame = CGRect(x: rect.origin.x, y: CGRectGetMaxY(rect) - 1, width: rect.size.width, height: 1)
            }
            return attr
        } else {
            return super.layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
        }
    }
}

class EdamameSeparator: UICollectionReusableView {
    var separatorColor = UIColor.blueColor()
    var separatorInsets = UIEdgeInsetsZero
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    func initialize() {
        self.backgroundColor = separatorColor
    }
//    override func drawRect(rect: CGRect) {
////        self.separatorColor.setFill()
////        let lineRect = CGRect(
////            x: rect.origin.x + separatorInsets.left,
////            y: rect.origin.y + separatorInsets.top,
////            width: rect.size.width - separatorInsets.left - separatorInsets.right,
////            height: rect.size.height - separatorInsets.top - separatorInsets.bottom
////        )
////        CGContextFillRect(UIGraphicsGetCurrentContext(), lineRect)
//    }
    
}