//
//  ModifyDemoViewController.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 5/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame
import RxSwift

class ModifyDemoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = UIColor.white
            collectionView.alwaysBounceVertical = true
        }
    }

    lazy var dataSource: RxDemoViewModel = {
        let ds = RxDemoViewModel(collectionView: self.collectionView)
        return ds
    }()

    
    deinit {
        print("[DEINIT]", self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func didTapDeleteButton() {
        self.dataSource.deleteItem()
    }

    @IBAction func didTapDeleteAllButton() {
        self.dataSource.deleteAll()
    }

    @IBAction func didTapAppendButton() {
        let section = 0
        self.dataSource.appendItem(section: section)
        self.dataSource.reloadData(animated: true)
    }

    @IBAction func didTapAppendSectionsButton() {
        self.dataSource.appendItem(section: 0)
        self.dataSource.appendItem(section: 1)
        self.dataSource.reloadData(animated: true)
    }

    @IBAction func didTapReloadSectionButton() {
        let section = 0
        self.dataSource[section].reloadData(animated: true)
    }

    @IBAction func didTapRemeveSectionButton() {
        let section = 0
        self.dataSource.removeSection(index: section, animated: true)
        _ = self.dataSource.createSection()
        self.dataSource.reloadData()
    }

    @IBAction func didTapAddSectionHeaderButton() {
        let section = 0
        self.dataSource.addHeader(section: section)
        self.dataSource.reloadData(animated: true)
    }

    @IBAction func didTapRemoveSectionHeaderButton() {
        let section = 0
        self.dataSource.deleteHeader(section: section)
        self.dataSource.reloadData(animated: true)
    }

    @IBAction func didTapToggleSectionButton() {
        let section = 0
        self.dataSource[section].hidden = !self.dataSource[section].hidden
        self.dataSource.reloadData(animated: false)
    }
}

class RxDemoViewModel: Edamame {

    func loadData(_ completion:(_ users: [RxUser]) -> Void) {
        var users = [RxUser]()
        for _ in 1...1 {
            users.append(RxUser(name: "foo", message: "tap me!"))
            users.append(RxUser(name: "bar", message: "tap me!"))
            users.append(RxUser(name: "hoge", message: "tap me!"))
            users.append(RxUser(name: "fuga", message: "tap me!"))
        }
        completion(users)
    }

    func setup() {
        self.registerNibFromClass(ModifyDemoCell.self)
        self.registerNibFromClass(ModifyDemoHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)

        self.loadData { (users) -> Void in
            let section = self.createSection()
            section.minimumLineSpacing = 0
            section.minimumInteritemSpacing = 0
            for user in users {
                section.appendItem(user, cellType: ModifyDemoCell.self) { [weak self] (item, indexPath) -> Void in
                    guard let user = item as? RxUser else { return }
                    self?.didTapUser(user: user)
                }
            }
            self.reloadData()
        }

        for section in 0...1 {
            _ = self[section]
            self.reloadData()
        }
    }

    func didTapUser(user: RxUser) {
        var targetIndexPaths: [IndexPath] = []
        self.sections.enumerated().forEach { (index, section) in
            section.items(RxUser.self).enumerated().forEach({ (index, _user) in
                if _user.name == user.name {
                    _user.message += " tapped"
                    targetIndexPaths.append(IndexPath(item: index, section: section.index))
                }
            })
        }
        targetIndexPaths.forEach { (indexPath) in
            self.setNeedsLayout(indexPath, animated: true)
        }
    }

    func deleteAllAndAddItems(section: Int = 0) {
        let section = self[section]
        let item = RxUser(name: "foo", message: "tap me!")
        section.removeAllItems()
        section.appendItem(item, cellType: ModifyDemoCell.self)
        section.appendItem(item, cellType: ModifyDemoCell.self)
        self.reloadData(animated: true)
    }

    func deleteItem(section: Int = 0) {
        let section = self[section]
        if section.numberOfItems > 0 {
            self.removeItemAtIndexPath(IndexPath(item: 0, section: section.index))
            self.reloadData(animated: true)
        }
    }

    func appendItem(section: Int = 0) {
        let section = self[section]
        let item = RxUser(name: "foo", message: "tap me!")
        section.appendItem(item, cellType: ModifyDemoCell.self) { [weak self] (item, indexPath) -> Void in
            guard let user = item as? RxUser else { return }
            self?.didTapUser(user: user)
        }
    }

    func deleteAll() {
        for sectionIndex in 0..<self.collectionView.numberOfSections {
            let section = self[sectionIndex]
            section.removeAllItems()
            section.removeSupplementaryItem(UICollectionView.elementKindSectionHeader)
        }
        self.reloadData(animated: true)
    }

    func randomDelete() {
        guard self.collectionView.numberOfSections > 0 else { return }
        let randomSection = Int(arc4random_uniform(UInt32(self.collectionView.numberOfSections)))
        let section = self[randomSection]
        guard section.numberOfItems > 0 else { return }
        let randomItem = Int(arc4random_uniform(UInt32(section.numberOfItems)))
        section.removeItemAtIndex(randomItem)
        self.reloadData(animated: true)
    }

    func addHeader(section: Int = 0) {
        let section = self[section]
        section.appendSupplementaryItem("Section \(section.index) Header", kind: UICollectionView.elementKindSectionHeader, viewType: ModifyDemoHeaderCell.self)
    }

    func deleteHeader(section: Int = 0) {
        let section = self[section]
        section.removeSupplementaryItem(UICollectionView.elementKindSectionHeader)
    }
}
