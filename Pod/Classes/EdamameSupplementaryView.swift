//
//  EdamameSupplementaryView.swift
//  Edamame
//
//  Created by 松尾 圭祐 on 2019/01/29.
//

import Foundation
public protocol EdamameSupplementaryView {
    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath)
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, section: Int) -> CGSize
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
