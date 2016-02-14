//
//  DemoViewController.swift
//  Edamame
//
//  Created by Matsuo Keisuke on 2/14/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Edamame

class ReactDemoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = UIColor.whiteColor()
            collectionView.alwaysBounceVertical = true
            dataSource = ReactDemoViewModel(collectionView: collectionView)
        }
    }
    var dataSource: ReactDemoViewModel!
    
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

class ReactDemoViewModel: Edamame {
    func loadData(completion:(users: [ReactUser]) -> Void) {
        var users = [ReactUser]()
        for _ in 0...100 {
            users.append(ReactUser(name: "foo", point: 0))
            users.append(ReactUser(name: "bar", point: 0))
            users.append(ReactUser(name: "hoge", point: 0))
            users.append(ReactUser(name: "fuga", point: 0))
        }
        completion(users: users)
    }
    func setup() {
        self.registerNibFromClass(ReactDemoCell.self)
        self.loadData { (users) -> Void in
            let section = self.createSection()
            for user in users {
                section.appendItem(user, cellType: ReactDemoCell.self)
            }
            self.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let user = self[indexPath] as? ReactUser else { return }
        user.point += 1
    }
}