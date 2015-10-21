//
//  ViewController.swift
//  Mankato Kiosk
//
//  Created by John Boucha on 10/3/15.
//  Copyright © 2015 John Boucha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       self.view.backgroundColor = UIColor(red: 254.0/255, green: 249.0/255, blue: 237.0/255, alpha: 1.0)
        
        titleLabel.textColor = UIColor(red: 44.0/255, green: 62.0/255, blue: 80.0/255, alpha: 1.0)
        descriptionLabel.textColor = UIColor(red: 44.0/255, green: 62.0/255, blue: 80.0/255, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

