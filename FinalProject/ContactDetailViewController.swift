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
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
//        let database = openDatabase();
        if let db = openDatabase(),
           let updatedContact = getContactByID(db: db, id: contactID) {
            
            detailContactID.text = String(updatedContact.cID)
            detailFirstName.text = updatedContact.cfirstName
            detailLastName.text = updatedContact.clastName
            detailEmail.text = updatedContact.cemail
            detailAddress.text = updatedContact.caddress
            detailPhone.text = updatedContact.cphone
            detailNotes.text = updatedContact.cnotes
        }
    
    }
    @IBAction func btnClosePressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func screenPressed(_ sender: UITapGestureRecognizer) {
        detailNotes.resignFirstResponder();
    }
    
    @IBAction func btnSaveNotePressed(_ sender: Any) {
        if let db = openDatabase() {
            updateNote(db: db);

        }
    }
    
    
    
    func updateNote(db: OpaquePointer) {
        
        let updateSQL = """
        UPDATE contacts
        SET Note = ?
        WHERE ContactID = ?
        """
        
        var updateQuery: OpaquePointer? = nil
        var updateMsg = ""
        if sqlite3_prepare_v2(db, updateSQL, -1, &updateQuery, nil) == SQLITE_OK {
            


            sqlite3_bind_text(updateQuery, 1, (detailNotes.text as NSString).utf8String, -1, nil)

            
            sqlite3_bind_int(updateQuery, 2, Int32(contactID))
            

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
        resignFirstResponder()
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
    
    func deleteContactByID(db:OpaquePointer, id: Int) -> Contact? {
        let deleteQuery = "DELETE * FROM contacts WHERE ContactID = ?"
        var statement: OpaquePointer? = nil
        
        var deleteMsg = "Are you sure you want to delete this contact?"
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(statement, 1, Int32(id))
            
           
            
            if sqlite3_step(deleteQuery) == SQLITE_DONE {
                deleteMsg = "Delete Successful"
                print("Update success")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db))
                deleteMsg = "Update Failed: \(errmsg)"
                print("Update failed: \(errmsg)")
            }
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            deleteMsg = "Prepare Failed: \(errmsg)"
            print("Prepare failed: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
            
            let alert = UIAlertController(title: "Update", message: updateMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            resignFirstResponder()
            
        
    }

    func getContactByID(db: OpaquePointer, id: Int) -> Contact? {
        
        let query = "SELECT * FROM contacts WHERE ContactID = ?"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                
                let contactID = Int(sqlite3_column_int(statement, 0))
                let firstName = String(cString: sqlite3_column_text(statement, 1))
                let lastName = String(cString: sqlite3_column_text(statement, 2))
                let email = String(cString: sqlite3_column_text(statement, 3))
                let address = String(cString: sqlite3_column_text(statement, 4))
                let phone = String(cString: sqlite3_column_text(statement, 5))
                let notes = String(cString: sqlite3_column_text(statement, 6))
                
                sqlite3_finalize(statement)
                
                return Contact(
                    contactID: contactID,
                    fname: firstName,
                    lname: lastName,
                    email: email,
                    address: address,
                    phone: phone,
                    notes: notes
                )
            }
        }
        
        sqlite3_finalize(statement)
        return nil
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
