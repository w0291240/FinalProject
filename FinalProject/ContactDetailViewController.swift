//
//  ContactDetailViewController.swift
//  FinalProject
//
//  Created by Jesse Crocker on 2026-03-31.
//

import UIKit
import SQLite3
import Foundation

class ContactDetailViewController: UIViewController {
    var contactList: [Contact] = []
    
    
    @IBOutlet weak var detailContactID: UILabel!
    @IBOutlet weak var detailFirstName: UILabel!
    @IBOutlet weak var detailLastName: UILabel!
    @IBOutlet weak var detailEmail: UILabel!
    @IBOutlet weak var detailAddress: UILabel!
    @IBOutlet weak var detailPhone: UILabel!
    @IBOutlet weak var detailNotes: UITextView!
    
    var contactID: Int = 0;
    var contactFirstName: String = "";
    var contactLastName: String = "";
    var contactEmail: String = "";
    var contactAddress: String = "";
    var contactPhone: String = "";
    var contactNotes: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database = openDatabase();
        contactList = readDB(db:database!);

        detailContactID.text = String(contactID);
        detailFirstName.text = contactFirstName;
        detailLastName.text = contactLastName;
        detailEmail.text = contactEmail;
        detailAddress.text = contactAddress;
        detailPhone.text = contactPhone;
        detailNotes.text = contactNotes;
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

    let selectSQL = "SELECT * FROM contacts"
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editSegue") {
            let contactEditVC = segue.destination as! ContactEditViewController
            
//            let contact = contactList[selectContact]
            
            contactEditVC.contactID = contactID
            contactEditVC.contactFirstName = contactFirstName
            contactEditVC.contactLastName = contactLastName
            contactEditVC.contactEmail = contactEmail
            contactEditVC.contactAddress = contactAddress
            contactEditVC.contactPhone = contactPhone
            contactEditVC.contactNotes = contactNotes
        }
    }


}
