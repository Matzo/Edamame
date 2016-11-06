//
//  DemoHeaderView.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 2/23/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame

class DemoHeaderView: UICollectionReusableView, EdamameSupplementaryView {
    @IBOutlet weak var label: UILabel!

    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let header = item as? String else { return }
        
        label.text = header
    }
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 44)
    }
}
