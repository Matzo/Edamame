//
//  RxDemoCell.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 5/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame
import RxSwift
import RxCocoa
import MirrorObject

class RxDemoCell: UICollectionViewCell, EdamameCell {
    
    static let viewHolder = UINib(nibName: String(RxDemoCell.self), bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! RxDemoCell
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 1.0, alpha: 1.0)
    }
    
    func configure(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) {
        guard let item = item as? RxUser else { return }

        nameLabel.text = item.name
        
        disposeBag = DisposeBag()
        item.rx_observeWeakly(String.self, "message").subscribeNext { [weak self] (message) in
            guard let _self = self else { return }
            _self.messageLabel.text = message
            collectionView.edamame?.setNeedsLayout(indexPath, animated: true)
        }.addDisposableTo(disposeBag)

    }
    
    static func sizeForItem(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.size.width * 0.5
        return calculateSize(item, collectionView: collectionView, indexPath: indexPath, cell: self.viewHolder, width: width)
    }
}

class RxUser : NSObject, MirrorObject {
    var name: String
    dynamic var message: String
    init(name: String, message: String) {
        self.name = name
        self.message = message
        super.init()
        startMirroring()
    }
    
    func identifier() -> String {
        return name
    }
    
    deinit {
        stopMirroring()
    }
}
