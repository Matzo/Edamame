//
//  ModifyDemoCell.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 5/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame
import RxSwift
import RxCocoa

class ModifyDemoCell: UICollectionViewCell, EdamameCell {
    
    static let viewHolder = UINib(nibName: String(describing: ModifyDemoCell.self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ModifyDemoCell
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 1.0, alpha: 1.0)
    }
    
    func configure(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let user = item as? RxUser else { return }

        nameLabel.text = user.name
        disposeBag = DisposeBag()
        user.rx.observeWeakly(String.self, "message").subscribe(onNext: { [weak self] (message) in
            guard let _self = self else { return }
            _self.messageLabel.text = message
        }).disposed(by: disposeBag)
    }
    
    static func sizeForItem(_ item: Any, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        let width = floor(collectionView.frame.size.width * 0.5)
        return calculateSize(item, collectionView: collectionView, indexPath: indexPath, cell: self.viewHolder, width: width)
    }
}

class RxUser: NSObject {
    var name: String
    @objc dynamic var message: String
    init(name: String, message: String) {
        self.name = name
        self.message = message
        super.init()
    }
}
