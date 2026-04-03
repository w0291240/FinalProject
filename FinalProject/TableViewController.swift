//
//  TableViewController.swift
//  FinalProject
//
//  Created by Jesse Crocker on 2026-03-22.
//

import UIKit
import SQLite3
import Foundation

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var contactList: [Contact] = []
    

    @IBOutlet weak var tableView: UITableView!
    
    //using viewWillAppear to reload the database when the tab is opened
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)

        let database = openDatabase();
        contactList = readDB(db:database!);
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.reloadData();
        
        
    }
    

    

    func openDatabase()-> OpaquePointer? {
        let dbFile = "Contacts_DB"
        let dbExt = "db"
        //var db: OpaquePointer?
        
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL =
        documentsURL!.appendingPathComponent(dbFile).appendingPathExtension(dbExt)
        
        if FileManager.default.fileExists(atPath: destURL.path) == false {
            
            let bundle = Bundle.main
            let DBURL = bundle.url(forResource: dbFile, withExtension: dbExt)
            
            if FileManager.default.fileExists(atPath: DBURL!.path) {
                
                do {
                    try FileManager.default.copyItem(atPath: DBURL!.path, toPath: destURL.path)
                } catch {
                    print("cannot copy file")
                }
            } else {
                print("DB already Exists.")
            }
        }
        
        var db: OpaquePointer? = nil
        
        if sqlite3_open(destURL.path, &db) != SQLITE_OK {
            debugPrint("can't open database")
            return nil
        } else {
            debugPrint("success")
            return db
        }
        
    }

   

func readDB(db: OpaquePointer) -> [Contact] {

    let selectSQL = "SELECT * FROM contacts ORDER BY LastName COLLATE NOCASE ASC"
    
    var selectQuery: OpaquePointer? = nil
    var contactList:[Contact] = []

    if sqlite3_prepare_v2(db, selectSQL, -1, &selectQuery, nil) == SQLITE_OK {

        while (sqlite3_step(selectQuery) == SQLITE_ROW) {
            
            let contactID = Int(sqlite3_column_int(selectQuery, 0))
            let firstName = String(cString: sqlite3_column_text(selectQuery, 1))
            let lastName = String(cString: sqlite3_column_text(selectQuery, 2))
            let email = String(cString: sqlite3_column_text(selectQuery, 3))
            let address = String(cString: sqlite3_column_text(selectQuery, 4))
            let phone = String(cString: sqlite3_column_text(selectQuery, 5))
            let notes = String(cString: sqlite3_column_text(selectQuery, 6))

            contactList.append(Contact(contactID:contactID,fname: firstName, lname: lastName,email:email, address: address, phone: phone, notes:notes))
        }

    } else {
        print("Select failed")
    }

    sqlite3_finalize(selectQuery)

    return contactList
}
    
    var selectContact: Int = 0;
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactCell = tableView.dequeueReusableCell(withIdentifier: "cellOne", for: indexPath) as! ContactTableViewCell
        
        let contact = contactList[indexPath.row];
        
        
        contactCell.contactName.text = "\(contact.cfirstName) \(contact.clastName)";
        return contactCell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectContact = indexPath.row;
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue") {
            let contactDetailVC = segue.destination as! ContactDetailViewController
            
            let contact = contactList[selectContact]
            
            contactDetailVC.contactID = contact.cID;
            contactDetailVC.contactFirstName = contact.cfirstName
            contactDetailVC.contactLastName = contact.clastName
            contactDetailVC.contactEmail = contact.cemail
            contactDetailVC.contactAddress = contact.caddress
            contactDetailVC.contactPhone = contact.cphone
            contactDetailVC.contactNotes = contact.cnotes
        }
    }
}
