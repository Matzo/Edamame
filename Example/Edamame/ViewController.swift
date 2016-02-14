//
//  ViewController.swift
//  Edamame
//
//  Created by Matzo on 02/14/2016.
//  Copyright (c) 2016 Matzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openDemoViewController() {
        let vc = DemoViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

