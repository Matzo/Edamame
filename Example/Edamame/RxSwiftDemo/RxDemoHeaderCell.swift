//
//  RxDemoHeaderCell.swift
//  Edamame
//
//  Created by 松尾 圭祐 on 2017/09/08.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import Edamame

class RxDemoHeaderCell: UICollectionViewCell, EdamameSupplementaryView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var titleLabel: UILabel!

    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let item = item as? String else { return }
        titleLabel.text = item
    }
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 64)
    }
}
