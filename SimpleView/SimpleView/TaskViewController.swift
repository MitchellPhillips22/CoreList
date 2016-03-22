//
//  TaskViewController.swift
//  SimpleView
//
//  Created by Mitchell Phillips on 3/21/16.
//  Copyright © 2016 Wasted Potential LLC. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    
    @IBOutlet weak var taskTextField: UITextField!
    
    @IBAction func addTaskButton(sender: UIButton) {
        
    performSegueWithIdentifier("unwindSegue", sender: self)
        
    }

    var arrayOfTasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    


}
