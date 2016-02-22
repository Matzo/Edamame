//
//  DemoHeaderView.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 2/23/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame

class DemoHeaderView: UICollectionReusableView, EdamameSupplementalyView {
    @IBOutlet weak var label: UILabel!

    func configure(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) {
        guard let header = item as? HeaderObj else { return }
        
        label.text = header.title
    }
    static func sizeForItem(item: Any, collectionView: UICollectionView, section: Int) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, 44)
    }
}

class HeaderObj {
    var title: String
    init(title: String) {
        self.title = title
    }
}