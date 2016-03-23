//
//  TableViewController.swift
//  SimpleView
//
//  Created by Mitchell Phillips on 3/21/16.
//  Copyright © 2016 Wasted Potential LLC. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //MARK: -Properties
    
    var arrayOfTasks = [NSManagedObject]()
    
    var moc = DataController().managedObjectContext
    
    var nameString = ""
    
    var dateFormatter = NSDateFormatter()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addTask(sender: UIBarButtonItem) {
        
        self.showAlert("Add a task", message: "Type task name here")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        fetchTasks()
        
    }
    //MARK: - Table View Functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrayOfTasks.count
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let t = arrayOfTasks[indexPath.row]
        
        if let didSelectBool = t.valueForKey("isCompleted") as? Bool {
            if didSelectBool == true {
                t.setValue(false, forKey: "isCompleted")
            } else if didSelectBool == false {
                t.setValue(true, forKey: "isCompleted")
            }
        }
        
        self.tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var date = NSDate()
        
        var isCompleted: Bool = false
        
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath) as! TaskTableViewCell
        
        let task = self.arrayOfTasks[indexPath.row]
        
        if let complete = task.valueForKey("isCompleted") as? Bool {
            isCompleted = complete
        }
        
        if let name = task.valueForKey("name") as? String {
            cell.taskNameLabel.text = name
        }
        if let dateVariable = task.valueForKey("created") as? NSDate {
            let createdDate = dateFormatter.stringFromDate(dateVariable)
            print(createdDate)
            cell.dateLabel.text = createdDate
            
            date = dateVariable
        }
        
        if isCompleted == true {
            
            cell.accessoryType = .Checkmark
            cell.backgroundColor = UIColor .lightGrayColor()
            cell.taskNameLabel.textColor = UIColor .whiteColor()
            
        }
        if isCompleted == false {
            
            cell.accessoryType = .None
            cell.taskNameLabel.textColor = UIColor .blackColor()
            
            if timeElapsed(date) < 120 {
                cell.backgroundColor = UIColor .greenColor()
            } else if timeElapsed(date) < 300 {
                cell.backgroundColor = UIColor .yellowColor()
            } else {
                cell.backgroundColor = UIColor .redColor()
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let taskToDelete = arrayOfTasks[indexPath.row]
            moc.deleteObject(taskToDelete)
            
            self.fetchTasks()
            self.saveAndLoad()
            
        }
    }
    
    //MARK: -Alert View
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) {
            (alertAction) -> Void in
            
            if let textField = alertController.textFields?.first,
                let name = textField.text {
                    
                    self.saveTask(name)
                    self.tableView.reloadData()
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (alertAction) -> Void in
            
        }
        
        alertController.addTextFieldWithConfigurationHandler {
            
            (textField) -> Void in
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil )
    }
    
    //MARK: -CoreData Save
    
    func saveTask(name: String) {
        
        if let taskEntity = NSEntityDescription.entityForName("Task", inManagedObjectContext: self.moc) {
            
            let task = NSManagedObject(entity: taskEntity, insertIntoManagedObjectContext: self.moc)
            
            let date = NSDate()
            
            task.setValue(name, forKey: "name")
            
            task.setValue(date, forKey: "created")
            
            task.setValue(false, forKey: "isCompleted")
            
            do {
                
                try self.moc.save()
                print("I saved task \(name)")
                
                self.arrayOfTasks.append(task)
                
            } catch {
                
                print("I couldn't save task \(name)")
            }
            
        }
        
    }
    
    func saveAndLoad() {

        do {
            
            try self.moc.save()
            
            self.tableView.reloadData()
            
        } catch {
            
            print("saveAndLoad doesn't work")
        }

    }
    
    func fetchTasks() {
        
        //Step 1
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        //Step 2
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        
        //Step 3 Add sort descripto
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            
            if let results = try self.moc.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                
                self.arrayOfTasks = results
                self.tableView.reloadData()
                
            }
            
        } catch {
            
            print("Error: couldn't fetch tasks")
        }
        
    }
    
    func timeElapsed(startTime: NSDate) -> NSTimeInterval {
        
        let endTime = NSDate()
        
        let formatter = NSNumberFormatter()
        
        formatter.maximumFractionDigits = 0
        
        let timeInterval: Double = endTime.timeIntervalSinceDate(startTime);
        
        let numberString = formatter.stringFromNumber(timeInterval)
        
        print(numberString)
        
        return timeInterval
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        fetchTasks()
        
        self.tableView.reloadData()
        
        refreshControl.endRefreshing()
        
    }
    
}

