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
        self.setupButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.dataSource.setNeedsLayout()
    }
    
    func setupButton() {
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: #selector(DemoViewController.insertCell))
        let removeButton = UIBarButtonItem.init(barButtonSystemItem: .Trash, target: self, action: #selector(DemoViewController.removeCell))
        navigationItem.rightBarButtonItems = [addButton, removeButton]
    }
    
    func insertCell() {
        let user = User(name: "Added")
        dataSource[0].insertItem(user, atIndex: 0)
        dataSource.reloadData(animated: true)
    }
    
    func removeCell() {
        if dataSource[0].numberOfItems > 0 {
            dataSource[0].removeItemAtIndex(0)
            dataSource.reloadData(animated: true)
        }
    }

    func removeAllCells() {
        if dataSource[0].numberOfItems > 0 {
            dataSource[0].removeAllItems()
            dataSource.reloadData(animated: true)
        }
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
        self.registerNibFromClass(DemoCalcBackgroundCell.self)
        self.registerNibFromClass(DemoHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        self.registerNibFromClass(DemoHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
        
        // Normal cell Demo
        self.loadData { (users) -> Void in
            let section = self[0]
            section.setCellType(DemoCell.self)
            section.appendSupplementaryItem("Title Name", kind: UICollectionElementKindSectionHeader, viewType: DemoHeaderView.self)
            section.appendSupplementaryItem("Footer Name", kind: UICollectionElementKindSectionFooter, viewType: DemoHeaderView.self)
            for user in users {
                section.appendItem(user)
            }
            
            self.reloadData()
        }
        
        // Calculate in background Demo
        self.loadData { (users) -> Void in
            let section = self[1]
            section.setCellType(DemoCell.self)
            section.appendSupplementaryItem("Title Name", kind: UICollectionElementKindSectionHeader, viewType: DemoHeaderView.self)
            section.appendSupplementaryItem("Footer Name", kind: UICollectionElementKindSectionFooter, viewType: DemoHeaderView.self)
            
            let text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
            
            for _ in 0..<5 {
                section.appendItem(text, cellType: DemoCalcBackgroundCell.self, calculateSizeInBackground: true) { (item, indexPath) -> Void in
                    guard let item = item as? String else { return }
                    print(item)
                }
            }
            
            self.reloadData()
        }
        
        // Dynamic Height Demo
        self.loadData { (users) -> Void in
            let section = self[2]
            section.setCellType(DemoCell.self)
            section.appendSupplementaryItem("Title Name", kind: UICollectionElementKindSectionHeader, viewType: DemoHeaderView.self)
            section.appendSupplementaryItem("Footer Name", kind: UICollectionElementKindSectionFooter, viewType: DemoHeaderView.self)
            
            let text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
            
            for _ in 0..<5 {
                section.appendItem(text, cellType: DemoDynamicHeightCell.self)
            }
            
            self.reloadData()
        }
        
        // Section Insets Demo
        self.loadData { (users) -> Void in
            let section = self[3]
            section.setCellType(DemoCell.self)
            section.inset = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
            section.appendSupplementaryItem("Title Name", kind: UICollectionElementKindSectionHeader, viewType: DemoHeaderView.self)
            section.appendSupplementaryItem("Footer Name", kind: UICollectionElementKindSectionFooter, viewType: DemoHeaderView.self)

            for user in users {
                section.appendItem(user)
            }
            
            self.reloadData()
        }
    }
}
