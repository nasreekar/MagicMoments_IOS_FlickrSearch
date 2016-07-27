//
//  FavTableViewController.swift
//  FS-Tabbed
//
//  Created by Abhijith Sreekar on 8/2/16.
//  Copyright © 2016 Abhijith Sreekar. All rights reserved.
//

import UIKit

class FavTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var favoritesDB:COpaquePointer = nil;
    
    var selectAll : COpaquePointer = nil
    var deleteStatement : COpaquePointer = nil
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1,sqlite3_destructor_type.self)

    
    var values : NSMutableArray! ;
    
    
    // @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) [0] as String
        print(paths)
        
        let docsdir = paths + "/fsfavorites.sqlite"
        
        if (sqlite3_open(docsdir, &favoritesDB)==SQLITE_OK)
        {
            let sql = "CREATE TABLE IF NOT EXISTS FSFAVORITES (ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT,COMMENTS TEXT, IMAGEURL TEXT)"
            if(sqlite3_exec(favoritesDB, sql,nil, nil, nil) != SQLITE_OK)
            {
                print("FAILED TO CREATE");
                print(sqlite3_errmsg(favoritesDB))
            }
        }
            
        else
        {
            print("Failed to open database")
            print(sqlite3_errmsg(favoritesDB))
        }
        prepareStatement();
        
    }
    
    
    
    func prepareStatement()
    {
        print("preparestatement")
        var sqlString : String
        
        
        sqlString = "SELECT title,comments, imageURL FROM fsfavorites";
        var cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(favoritesDB, cSql!, -1, &selectAll, nil)
        
        sqlString = "DELETE FROM FSFAVORTIES WHERE TITLE = ?"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(favoritesDB, cSql!, -1, &deleteStatement,nil)
        
    }
    
    func reload() {
        
        values = NSMutableArray();
        
        print(selectAll)
        
        while(sqlite3_step(selectAll) == SQLITE_ROW)
        {
            let title_buf = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(selectAll, 0)))
            let comments_buf = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(selectAll, 1)))
            let url_buf = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(selectAll, 2)))
            
            let fav = favorites(title: title_buf!, comments: comments_buf!, imageURL: url_buf! )
            
            values.addObject(fav);
            
        }
        
        sqlite3_reset(selectAll);
        tableView.reloadData();
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewwillapper");
        // self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        values = NSMutableArray();
        super.viewWillAppear(animated)
        tableView.delegate = self;
        tableView.dataSource = self;
        reload();
        tableView.reloadData();
    }
    

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return objects.count
        return values.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
        
        let fav = values[indexPath.row] as! favorites
        cell.textLabel?.text = fav.title;
        cell.detailTextLabel?.text = fav.comments;
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let fav = values[indexPath.row] as! favorites
                (segue.destinationViewController as! FavDetailViewController).favPhoto = fav
            }
        }
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let fav = values[indexPath.row] as! favorites
            let titleStr = fav.title
            sqlite3_bind_text(deleteStatement, 1, titleStr, -1, SQLITE_TRANSIENT)
            
            if(sqlite3_step(deleteStatement) == SQLITE_DONE)
            {
                print("favorites deleted")
                
            }
            else{
                print("Error code: " , sqlite3_errcode(favoritesDB));
                let error = String.fromCString(sqlite3_errmsg(favoritesDB));
                print("Error msg: ", error)
            }
            sqlite3_reset(deleteStatement)
            sqlite3_clear_bindings(deleteStatement)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == UITableViewCellEditingStyle.Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}