//
//  ContactEditViewController.swift
//  FinalProject
//
//  Created by Jesse Crocker on 2026-04-01.
//

import UIKit
import SQLite3
import Foundation

class ContactEditViewController: UIViewController {
    @IBOutlet weak var tfFirstNameEdit: UITextField!
    @IBOutlet weak var tfLastNameEdit: UITextField!
    @IBOutlet weak var tfEmailEdit: UITextField!
    @IBOutlet weak var tfAddressEdit: UITextField!
    @IBOutlet weak var tfPhoneEdit: UITextField!
    @IBOutlet weak var tvNotesEdit: UITextView!
    

    var contactID: Int = 0;
    var contactFirstName: String = "";
    var contactLastName: String = "";
    var contactEmail: String = "";
    var contactAddress: String = "";
    var contactPhone: String = "";
    var contactNotes: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        detailContactID.text = String(contactID);
        tfFirstNameEdit.text = contactFirstName;
        tfLastNameEdit.text = contactLastName;
        tfEmailEdit.text = contactEmail;
        tfAddressEdit.text = contactAddress;
        tfPhoneEdit.text = contactPhone;
        tvNotesEdit.text = contactNotes;
    }
    @IBAction func screenPressed(_ sender: Any) {
        tfFirstNameEdit.resignFirstResponder()
        tfLastNameEdit.resignFirstResponder()
        tfEmailEdit.resignFirstResponder()
        tfAddressEdit.resignFirstResponder()
        tfFirstNameEdit.resignFirstResponder()
        tfPhoneEdit.resignFirstResponder()
    }
    
    @IBAction func btnUpdatePressed(_ sender: UIButton) {
        if let db = openDatabase() {
            updateContact(db: db)
        }
    }
    
    func updateContact(db: OpaquePointer) {
        
        let updateSQL = """
        UPDATE contacts
        SET FirstName = ?, LastName = ?, Email = ?, Address = ?, Phone = ?
        WHERE ContactID = ?
        """
        
        var updateQuery: OpaquePointer? = nil
        var updateMsg = ""
        if sqlite3_prepare_v2(db, updateSQL, -1, &updateQuery, nil) == SQLITE_OK {
            

            sqlite3_bind_text(updateQuery, 1, (tfFirstNameEdit.text! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateQuery, 2, (tfLastNameEdit.text! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateQuery, 3, (tfEmailEdit.text! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateQuery, 4, (tfAddressEdit.text! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateQuery, 5, (tfPhoneEdit.text! as NSString).utf8String, -1, nil)

            
            sqlite3_bind_int(updateQuery, 6, Int32(contactID))
            

            if sqlite3_step(updateQuery) == SQLITE_DONE {
                updateMsg = "Update Successful"
                print("Update success")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db))
                updateMsg = "Update Failed: \(errmsg)"
                print("Update failed: \(errmsg)")
            }
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            updateMsg = "Prepare Failed: \(errmsg)"
            print("Prepare failed: \(errmsg)")
        }

        // Clean up
        sqlite3_finalize(updateQuery)

        // Alert user
        let alert = UIAlertController(title: "Update", message: updateMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
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

}
