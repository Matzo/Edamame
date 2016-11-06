//
//  DemoDynamicHeightCell.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 2/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame

class DemoDynamicHeightCell: UICollectionViewCell, EdamameCell {
    
    @IBOutlet weak var label: UILabel!
    
    static let viewHolder = UINib(nibName: String(describing: DemoDynamicHeightCell.self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DemoDynamicHeightCell

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let string = item as? String else { return }
        
        label.text = string
    }
    
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        guard let string = item as? String else { return CGSize.zero }
        return self.calculateSize(string, collectionView: collectionView, indexPath: indexPath, cell: viewHolder, width: collectionView.frame.size.width)
    }
}
