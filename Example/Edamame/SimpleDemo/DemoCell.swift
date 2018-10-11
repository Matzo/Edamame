//
//  DemoCell.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 2/14/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame

class DemoCell: UICollectionViewCell, EdamameCell {
    
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.green
    }
    
    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let user = item as? User else { return }
        
        self.label.text = user.name
    }

    static func sizeForItem(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 4
        let margin: CGFloat = 8
        let width = (collectionView.frame.size.width - (margin * (columns - 1))) / columns
        return CGSize(width: width , height: 44)
    }
}

class User {
    var name: String
    init(name: String) {
        self.name = name
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        guard lhs.name == rhs.name else { return false }
        return true
    }
}
