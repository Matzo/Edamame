//
//  ReactDemoCell.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 2/14/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import MirrorObject
import Edamame
import ReactKit

class ReactDemoCell : UICollectionViewCell, EdamameCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.yellowColor()
    }
    
    var pointStream: Stream<Int>?
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                self.backgroundColor = UIColor.lightGrayColor()
            } else {
                self.backgroundColor = UIColor.yellowColor()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.pointStream?.cancel()
    }
    
    func configure(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) {
        guard let user = item as? ReactUser else { return }
        
        let stream = KVO.stream(user, "point") |> map { $0 as! Int }
        stream ~> { [weak self] (point: Int) in
            self?.pointLabel.text = "\(point)"
        }

        self.pointStream = stream
        self.nameLabel.text = user.name
        self.pointLabel.text = "\(user.point)"
    }

    static func sizeForItem(item: Any, collectionView: UICollectionView, indexPath: NSIndexPath) -> CGSize {
        let columns: CGFloat = 3
        let margin: CGFloat = 8
        let width = (collectionView.frame.size.width - (margin * (columns - 1))) / columns
        return CGSize(width: width , height: 44)
    }
}

class ReactUser : NSObject, MirrorObject  {
    var name: String
    dynamic var point: Int
    init(name: String, point: Int) {
        self.name = name
        self.point = point
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