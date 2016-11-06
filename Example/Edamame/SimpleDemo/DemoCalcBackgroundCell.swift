//
//  DemoCalcBackgroundCell.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 2/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame

class DemoCalcBackgroundCell: UICollectionViewCell, EdamameCell {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.yellow
    }

    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let string = item as? String else { return }
        
        label.text = string
    }
    
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        guard let string = item as? String else { return CGSize.zero }

        Thread.sleep(forTimeInterval: 0.1)
        let bounds = (string as NSString).boundingRect(with: CGSize(width: collectionView.frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: nil, context: nil)

        return CGSize(width: collectionView.frame.size.width, height: bounds.size.height)
    }
}
