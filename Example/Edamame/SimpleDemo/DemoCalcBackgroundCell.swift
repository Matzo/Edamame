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
        self.contentView.backgroundColor = UIColor.yellowColor()
    }

    func configure(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) {
        guard let string = item as? String else { return }
        
        label.text = string
    }
    
    static func sizeForItem(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) -> CGSize {
        guard let string = item as? String else { return CGSize.zero }

        NSThread.sleepForTimeInterval(0.1)
        let bounds = (string as NSString).boundingRectWithSize(CGSize(width: collectionView.frame.size.width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: nil, context: nil)

        return CGSize(width: collectionView.frame.size.width, height: bounds.size.height)
    }
}
