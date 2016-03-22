//
//  TableViewController.swift
//  SimpleView
//
//  Created by Mitchell Phillips on 3/21/16.
//  Copyright © 2016 Wasted Potential LLC. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    var arrayOfTasks = [Task]()
    
    @IBOutlet weak var tableView: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwindSegue" {
            
            let taskViewController = segue.sourceViewController as! TaskViewController
            
            let t = Task()
            
            if let name = taskViewController.taskTextField.text {
                t.name = name
            }
            
            self.arrayOfTasks.append(t)
            
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrayOfTasks.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell")!
        
        let t = arrayOfTasks[indexPath.row]
        
        cell.textLabel?.text = t.name
        
        return cell
    }
}

