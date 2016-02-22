//
//  DemoViewController.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 2/14/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame

class DemoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = UIColor.whiteColor()
            collectionView.alwaysBounceVertical = true
            dataSource = DemoViewModel(collectionView: collectionView)
        }
    }
    var dataSource: DemoViewModel!
    
    deinit {
        print("[DEINIT]", self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource.setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.dataSource.setNeedsLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class DemoViewModel: Edamame {
    func loadData(completion:(users: [User]) -> Void) {
        let users = [
            User(name: "foo"),
            User(name: "bar"),
            User(name: "hoge"),
            User(name: "fuga"),
        ]
        completion(users: users + users + users)
    }
    func setup() {
        self.registerNibFromClass(DemoCell.self)
        self.registerNibFromClass(DemoHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        self.registerNibFromClass(DemoHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
        self.loadData { (users) -> Void in
            let section = self.createSection()
            section.appendSupplementaryItem(HeaderObj(title: "Title Name"), kind: UICollectionElementKindSectionHeader, viewType: DemoHeaderView.self)
            section.appendSupplementaryItem(HeaderObj(title: "Footer Name"), kind: UICollectionElementKindSectionFooter, viewType: DemoHeaderView.self)
            for user in users {
                section.appendItem(user, cellType: DemoCell.self)
            }
            self.reloadData()
        }
    }
}