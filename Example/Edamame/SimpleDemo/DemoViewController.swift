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
            User(name: "daa"),
        ]
        completion(users: users + users + users)
    }
    func setup() {
        self.registerNibFromClass(DemoCell.self)
        self.registerNibFromClass(DemoDynamicHeightCell.self)
        self.registerNibFromClass(DemoHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        self.registerNibFromClass(DemoHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
        self.loadData { (users) -> Void in
            let section = self[0]
            section.setCellType(DemoCell.self)
            section.appendSupplementaryItem("Title Name", kind: UICollectionElementKindSectionHeader, viewType: DemoHeaderView.self)
            section.appendSupplementaryItem("Footer Name", kind: UICollectionElementKindSectionFooter, viewType: DemoHeaderView.self)
            for user in users {
                section.appendItem(user)
            }
            
            let text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
            
            
            for _ in 0..<5 {
                section.appendItem(text, cellType: DemoDynamicHeightCell.self, calculateSizeInBackground: true)
            }
            
            for user in users {
                section.appendItem(user)
            }
            
            for _ in 0..<5 {
                section.appendItem(text, cellType: DemoDynamicHeightCell.self, calculateSizeInBackground: true)
            }
            
            self.reloadData()
        }
    }
}