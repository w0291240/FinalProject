//
//  InputViewController.swift
//  FinalProject
//
//  Created by Jesse Crocker on 2026-03-22.
//

import UIKit
import SQLite3
import Foundation

class InputViewController: UIViewController {
//    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tvNotes: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.textView.layer.borderWidth = 1;
//        self.textView.layer.backgroundColor = CGColor(red: 0, green: 100, blue: 0, alpha: 1)
//        self.textView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
//        
//        self.textView.layer.cornerRadius = 6;

        // Do any additional setup after loading the view.
    }
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        tfFirstName.resignFirstResponder();
        tfLastName.resignFirstResponder();
        tfEmail.resignFirstResponder();
        tfAddress.resignFirstResponder();
        tfPhone.resignFirstResponder();
        tvNotes.resignFirstResponder();
    }
    
    @IBAction func btnSavePressed(_ sender: UIButton) {
        var saveMsg = "Save Contact?"
        
        let controller = UIAlertController(title: "Save", message: saveMsg, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        let saveButton = UIAlertAction(title: "Clear", style: .default) { (action) in
            let database = self.openDatabase()
            
            if self.tfFirstName.text != "" {
                self.insert(
                    firstName: self.tfFirstName.text!,
                    lastName: self.tfLastName.text!,
                    email: self.tfEmail.text!,
                    address: self.tfAddress.text!,
                    phone: self.tfPhone.text!,
                    notes: self.tvNotes.text!,
                    db: database!)
            }
            self.clearFields();
        }
        controller.addAction(cancelButton)
        controller.addAction(saveButton)
        self.present(controller, animated: true)
    }
    
    func clearFields() {
        tfFirstName.text = ""
        tfLastName.text = ""
        tfEmail.text = ""
        tfAddress.text = ""
        tfPhone.text = ""
        tvNotes.text = ""
    }
    
    
    @IBAction func btnClearPressed(_ sender: UIButton) {
        
        var clearMsg = "Are you sure you want to clear all fields?"
        
        let controller = UIAlertController(title: "Clear", message: clearMsg, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        let clearButton = UIAlertAction(title: "Clear", style: .destructive) { (action) in
            self.clearFields();
        }
        controller.addAction(cancelButton)
        controller.addAction(clearButton)
        self.present(controller, animated: true)


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

    func insert(firstName: String, lastName: String, email: String, address: String, phone: String, notes:String, db: OpaquePointer) {
        let insertSQL = "INSERT INTO Courses(FirstName, LastName, Email, Address, Phone) VALUES (?,?,?,?)"
        var insertQuery: OpaquePointer? = nil
        var insertMsg = ""

        if sqlite3_prepare_v2(db, insertSQL, -1, &insertQuery, nil) == SQLITE_OK {

            sqlite3_bind_text(insertQuery, 1, (firstName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertQuery, 2, (lastName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertQuery, 3, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertQuery, 4, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertQuery, 5, (phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertQuery, 6, (notes as NSString).utf8String, -1, nil)
            

            if sqlite3_step(insertQuery) == SQLITE_DONE {
                insertMsg = "Insert Successful"
                print("success")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db))
                insertMsg = "Insert Failed: \(errmsg)"
                print("Insert fail: \(errmsg)")
            }

        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            insertMsg = "Prepare Failed: \(errmsg)"
            print("Prepare fail: \(errmsg)")
        }

        sqlite3_finalize(insertQuery)

        let controller = UIAlertController(title: "Insert", message: insertMsg, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: "Ok", style: .default)
        controller.addAction(actionButton)
        self.present(controller, animated: true)

        tfFirstName.text = ""
        tfLastName.text = ""
        tfEmail.text = ""
        tfAddress.text = ""
        tfPhone.text = ""
        tvNotes.text = ""
    }

}

func readDB(db: OpaquePointer) -> [Contact] {

    let selectSQL = "SELECT * FROM contacts"
    
    var selectQuery: OpaquePointer? = nil
    var contactList:[Contact] = []

    if sqlite3_prepare_v2(db, selectSQL, -1, &selectQuery, nil) == SQLITE_OK {

        while (sqlite3_step(selectQuery) == SQLITE_ROW) {

            let firstName = String(cString: sqlite3_column_text(selectQuery, 0))
            let lastName = String(cString: sqlite3_column_text(selectQuery, 1))
            let email = String(cString: sqlite3_column_text(selectQuery, 2))
            let address = String(cString: sqlite3_column_text(selectQuery, 3))
            let phone = String(cString: sqlite3_column_text(selectQuery, 4))

            contactList.append(Contact(fname: firstName, lname: lastName,email:email, address: address, phone: phone))
        }

    } else {
        print("Select failed")
    }

    sqlite3_finalize(selectQuery)

    return contactList
}


class Contact {
    
    var cfirstName: String
    var clastName: String
    var cemail: String
    var caddress: String
    var cphone: String
    
    init(fname:String, lname:String, email:String, address:String, phone:String){
        cfirstName = fname
        clastName = lname
        cemail = email
        caddress = address
        cphone = phone
    }
}

